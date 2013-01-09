Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 72A816B0070
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 03:26:37 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id r4so475751qaq.12
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 00:26:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130105031817.GA8650@localhost>
References: <1356847190-7986-1-git-send-email-linkinjeon@gmail.com>
	<20130105031817.GA8650@localhost>
Date: Wed, 9 Jan 2013 17:26:36 +0900
Message-ID: <CAKYAXd-kTOBwZfW=17Ta0wLB4HWzkk5ta3AdT0cPRK3z2zsLUA@mail.gmail.com>
Subject: Re: [PATCH] writeback: fix writeback cache thrashing
From: Namjae Jeon <linkinjeon@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, liwanp@linux.vnet.ibm.com, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Jan Kara <jack@suse.cz>, Dave Chinner <dchinner@redhat.com>, Simon Jeons <simon.jeons@gmail.com>

>
> Yeah, that IO pattern is not good. Perhaps it's 6 small IOs in /one/
> second?  However that's not quite in line with "sleep 2sec" in your
> workload description. Note that I assume flush-8:0 works on a hard
> disk, so each flush-8:0 line indicates roughly 1 second interval
> elapsed. It would be much more clear if the printk timestamps are
> turned on (CONFIG_PRINTK_TIME=3Dy).

Okay, I enabled CONFIG_PRINTK_TIME in kernel.
I did small change in my workload - removed 2 sec sleep:

Process A: huge Write on sda
Process B: doing while [1]; read 1024K + rewrite 1024K on sdb

Here sda: USB HDD with write speed ~ 30 MB/s
Here sdb: USB Flash with write speed ~ 5 MB/s

[Test setup: ARM dual core CPU, 512 MB RAM]

Please find below debug log with original kernel:

[  229.198121] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      94592 KB,
bdi_dirty_limit =3D      55088 KB
[  232.289630] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        724 KB
[  232.301741] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        724 KB
[  232.311931] [1]:flush--8:16 : BDI_RECLAIMABLE =3D         64 KB,
bdi_dirty_limit =3D        724 KB
[  232.401708] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      88576 KB,
bdi_dirty_limit =3D      55168 KB
[  232.496078] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      94848 KB,
bdi_dirty_limit =3D      54976 KB
[  232.511644] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D       1084 KB
[  232.525624] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D       1084 KB
[  232.554873] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D       1076 KB
[  233.495648] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        512 KB,
bdi_dirty_limit =3D       1152 KB
[  233.503541] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        576 KB,
bdi_dirty_limit =3D       1152 KB
[  233.514282] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D       1152 KB
[  233.537715] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        128 KB,
bdi_dirty_limit =3D       1228 KB
[  233.553075] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        448 KB,
bdi_dirty_limit =3D       1228 KB
[  233.562214] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D       1228 KB
[  235.892394] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      82112 KB,
bdi_dirty_limit =3D      54848 KB
[  238.585652] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        728 KB
[  238.597671] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        728 KB
[  238.612104] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        728 KB
[  238.738163] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        576 KB,
bdi_dirty_limit =3D        892 KB
[  238.747117] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        640 KB,
bdi_dirty_limit =3D        888 KB
[  238.756542] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        924 KB
[  238.817905] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      91136 KB,
bdi_dirty_limit =3D      54972 KB
[  238.826022] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      91712 KB,
bdi_dirty_limit =3D      55016 KB
[  239.726429] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        448 KB,
bdi_dirty_limit =3D       1024 KB
[  239.734379] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        448 KB,
bdi_dirty_limit =3D       1024 KB
[  239.744833] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D       1024 KB
[  239.928073] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        896 KB,
bdi_dirty_limit =3D       1240 KB
[  239.936026] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        896 KB,
bdi_dirty_limit =3D       1240 KB
[  239.946683] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D       1240 KB
[  242.214657] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      91904 KB,
bdi_dirty_limit =3D      54816 KB
[  244.666688] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        820 KB
[  244.678468] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        820 KB
[  244.703922] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        820 KB
[  245.319828] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      93056 KB,
bdi_dirty_limit =3D      55080 KB
[  245.327903] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      93056 KB,
bdi_dirty_limit =3D      55080 KB
[  248.356755] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      93184 KB,
bdi_dirty_limit =3D      55484 KB
[  249.753702] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        480 KB
[  249.771723] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        480 KB
[  249.791753] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        476 KB
[  250.769776] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        736 KB
[  250.785677] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        736 KB
[  250.807895] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        732 KB
[  251.005127] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        512 KB,
bdi_dirty_limit =3D       1036 KB
[  251.013080] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D       1036 KB
[  251.024465] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D       1036 KB
[  251.616792] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      90112 KB,
bdi_dirty_limit =3D      55024 KB
[  251.624734] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      90112 KB,
bdi_dirty_limit =3D      55024 KB
[  252.012840] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        512 KB,
bdi_dirty_limit =3D       1168 KB
[  252.029653] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D       1164 KB
[  252.048298] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D       1160 KB
[  252.261246] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D       1400 KB
[  252.269284] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D       1400 KB
[  252.281098] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D       1396 KB
[  253.166740] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        512 KB,
bdi_dirty_limit =3D       1332 KB
[  253.174682] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        512 KB,
bdi_dirty_limit =3D       1332 KB
[  253.184909] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D       1364 KB
[  254.916909] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      90240 KB,
bdi_dirty_limit =3D      54776 KB
[  258.174616] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      77056 KB,
bdi_dirty_limit =3D      55244 KB
[  258.361648] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        752 KB
[  258.373363] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        752 KB
[  258.396216] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        748 KB
[  259.289888] [1]:flush--8:16 : BDI_RECLAIMABLE =3D         64 KB,
bdi_dirty_limit =3D        820 KB
[  259.302663] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        128 KB,
bdi_dirty_limit =3D        820 KB
[  259.315969] [1]:flush--8:16 : BDI_RECLAIMABLE =3D         64 KB,
bdi_dirty_limit =3D        864 KB
[  261.029994] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      94656 KB,
bdi_dirty_limit =3D      55176 KB
[  261.087820] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      94656 KB,
bdi_dirty_limit =3D      55180 KB
[  264.177467] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      90688 KB,
bdi_dirty_limit =3D      55448 KB
[  264.345671] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        496 KB
[  264.360635] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        496 KB
[  264.382961] [1]:flush--8:16 : BDI_RECLAIMABLE =3D         64 KB,
bdi_dirty_limit =3D        492 KB
[  264.421008] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        192 KB,
bdi_dirty_limit =3D        532 KB
[  264.429271] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        192 KB,
bdi_dirty_limit =3D        532 KB
[  264.440572] [1]:flush--8:16 : BDI_RECLAIMABLE =3D         64 KB,
bdi_dirty_limit =3D        572 KB
[  265.271753] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        128 KB,
bdi_dirty_limit =3D        540 KB
[  265.279611] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        128 KB,
bdi_dirty_limit =3D        540 KB
[  265.290591] [1]:flush--8:16 : BDI_RECLAIMABLE =3D         64 KB,
bdi_dirty_limit =3D        576 KB
[  267.490909] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      87488 KB,
bdi_dirty_limit =3D      55364 KB
[  267.584972] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      92992 KB,
bdi_dirty_limit =3D      55388 KB
[  270.329631] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        424 KB
[  270.344304] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        424 KB
[  270.355331] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        424 KB
[  270.809216] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      92544 KB,
bdi_dirty_limit =3D      55536 KB
[  271.238783] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        128 KB,
bdi_dirty_limit =3D        468 KB
[  271.246592] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        192 KB,
bdi_dirty_limit =3D        468 KB
[  271.257163] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        496 KB
[  274.248876] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      90304 KB,
bdi_dirty_limit =3D      55592 KB
[  276.377686] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        324 KB
[  276.389785] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        324 KB
[  276.416520] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        320 KB
[  276.482112] [1]:flush--8:16 : BDI_RECLAIMABLE =3D         64 KB,
bdi_dirty_limit =3D        376 KB
[  276.494751] [1]:flush--8:16 : BDI_RECLAIMABLE =3D         64 KB,
bdi_dirty_limit =3D        376 KB
[  276.508280] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        376 KB
[  277.550003] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      89856 KB,
bdi_dirty_limit =3D      55400 KB
[  277.558115] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      89856 KB,
bdi_dirty_limit =3D      55400 KB
[  280.750010] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        388 KB
[  280.761704] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        388 KB
[  280.788278] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        388 KB
[  280.827970] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        440 KB
[  280.835839] [1]:flush--8:16 : BDI_RECLAIMABLE =3D          0 KB,
bdi_dirty_limit =3D        440 KB
[  280.848928] [1]:flush--8:16 : BDI_RECLAIMABLE =3D         64 KB,
bdi_dirty_limit =3D        468 KB
[  280.889357] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      78016 KB,
bdi_dirty_limit =3D      55496 KB

As mentioned above, when global memory is more than background dirty thresh=
hold
over_bground_thresh is mostly returning true even for small dirty chunks
like 64K, 128K etc..


>
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D 92032 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D 91968 KB
>> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =3D   192 KB
>> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =3D  1024 KB
>> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =3D    64 KB
>> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =3D   192 KB
>> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =3D   576 KB
>> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =3D     0 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D 84352 KB
>> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =3D   192 KB
>> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =3D   512 KB
>> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =3D     0 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D 92608 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D 92544 KB
>>
>> As mentioned in above log, when global dirty memory > global
>> background_thresh
>> small cached data is also forced to flush by flush-8:16.
>>
>> If removing global background_thresh checking code, we can reduce cache
>> thrashing of frequently used small data.
>> And It will be great if we can reserve a portion of writeback cache usin=
g
>> min_ratio.
>
>> After applying patch:
>> $ echo 5 > /sys/block/sdb/bdi/min_ratio
>> $ cat /sys/block/sdb/bdi/min_ratio
>> 5
>
> The below log looks all perfect. However the min_ratio setup is a
> problem. If possible, I'd like the final patch being able to work
> reasonably well with min_ratio=3D0 (the system default), too.
>
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  56064 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  56704 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  84160 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  96960 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  94080 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  93120 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  93120 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  91520 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  89600 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  93696 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  93696 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  72960 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  90624 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  90624 KB
>> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =3D  90688 KB
>
>> As mentioned in the above logs, once cache is reserved for Process B,
>> and patch is applied there is less writeback cache thrashing on sdb
>> by frequent forced writeback by flush-8:16 in over_bground_thresh.
>>
>> After all, small cached data will be flushed by periodic writeback
>> once every dirty_writeback_interval.
>>
>> Suggested-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>
>> Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
>> Cc: Fengguang Wu <fengguang.wu@intel.com>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Dave Chinner <dchinner@redhat.com>
>> ---
>>  fs/fs-writeback.c |    4 ----
>>  1 file changed, 4 deletions(-)
>>
>> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
>> index 310972b..070b773 100644
>> --- a/fs/fs-writeback.c
>> +++ b/fs/fs-writeback.c
>> @@ -756,10 +756,6 @@ static bool over_bground_thresh(struct
>> backing_dev_info *bdi)
>>
>>  	global_dirty_limits(&background_thresh, &dirty_thresh);
>>
>> -	if (global_page_state(NR_FILE_DIRTY) +
>> -	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
>> -		return true;
>> -
>
> That global test should be kept in some form (see Jan's proposal).
> Because the below per-bdi test can be inaccurate in various ways:
>
> - bdi_stat() may have errors up to bdi_stat_error()
>
> - bdi_dirty_limit() may be arbitrarily shifted by min_ratio etc.
>
> - bdi_dirty_limit() may be totally wrong due to the estimation in
>   bdi_writeout_fraction() is in its initial value 0, or is still
>   trying to catch up with sudden workload changes.
>
>>  	if (bdi_stat(bdi, BDI_RECLAIMABLE) >
>>  				bdi_dirty_limit(bdi, background_thresh))
>>  		return true;
>
> I suspect even removing the global test as in your patch, the above
> bdi test will still mostly return true for your described workload,
> due to bdi_dirty_limit() returning a value close to 0, because the
> writeout fraction of sdb is close to 0.
>
> You cleverly avoided this in your test by raising min_ratio to 5.
> However I'd suggest to test with min_ratio=3D0 and try solutions that
> can work well in such default configuration.

Yes, after applying min_ratio =3D 0, cache thrashing will be reduced
 but it will not fixed 100%. Please find below logs with min_ratio =3D 0:

[  446.250089] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      78208 KB,
bdi_dirty_limit =3D      55308 KB
[  447.961688] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        548 KB
[  447.969524] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        548 KB
[  448.177532] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        924 KB
[  448.189900] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        924 KB
[  449.005822] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      92928 KB,
bdi_dirty_limit =3D      55160 KB
[  452.052060] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      93696 KB,
bdi_dirty_limit =3D      55308 KB
[  453.225619] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        568 KB
[  453.233652] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        568 KB
[  453.451407] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        876 KB
[  453.463401] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        876 KB
[  455.437187] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      94976 KB,
bdi_dirty_limit =3D      55068 KB
[  457.573684] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        640 KB
[  457.589837] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        640 KB
[  458.648492] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      91776 KB,
bdi_dirty_limit =3D      55172 KB
[  458.656590] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      91776 KB,
bdi_dirty_limit =3D      55172 KB
[  458.657641] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        832 KB
[  458.657664] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        832 KB
[  461.771683] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      88128 KB,
bdi_dirty_limit =3D      55336 KB
[  464.164928] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        484 KB
[  464.185637] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        480 KB
[  464.254258] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        192 KB,
bdi_dirty_limit =3D        508 KB
[  464.262889] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        192 KB,
bdi_dirty_limit =3D        508 KB
[  464.998619] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      89600 KB,
bdi_dirty_limit =3D      55268 KB
[  465.006586] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      89600 KB,
bdi_dirty_limit =3D      55268 KB
[  468.355120] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      78016 KB,
bdi_dirty_limit =3D      55568 KB
[  469.289622] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        384 KB
[  469.297527] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        384 KB
[  469.445361] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        768 KB,
bdi_dirty_limit =3D        552 KB
[  469.453357] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        768 KB,
bdi_dirty_limit =3D        552 KB
[  470.431779] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        812 KB
[  470.439594] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        812 KB
[  470.631494] [2]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D       1160 KB
[  470.643585] [2]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D       1160 KB
[  471.111608] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      90496 KB,
bdi_dirty_limit =3D      54900 KB
[  471.119563] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      90496 KB,
bdi_dirty_limit =3D      54900 KB
[  471.686473] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D       1284 KB
[  471.694414] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D       1284 KB
[  474.252738] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      88192 KB,
bdi_dirty_limit =3D      54868 KB
[  474.261279] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D       1124 KB
[  474.273592] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D       1124 KB
[  477.701264] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      82112 KB,
bdi_dirty_limit =3D      55148 KB
[  477.713485] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      82176 KB,
bdi_dirty_limit =3D      55164 KB
[  480.281635] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        592 KB
[  480.289460] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        592 KB
[  480.676031] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      90432 KB,
bdi_dirty_limit =3D      55160 KB
[  480.808089] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        856 KB
[  480.829621] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        852 KB
[  483.733722] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        780 KB
[  483.745819] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        780 KB
[  484.021687] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      90816 KB,
bdi_dirty_limit =3D      54908 KB
[  484.029652] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D       1128 KB
[  484.045597] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D       1124 KB
[  485.063624] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D       1256 KB
[  485.071569] [2]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D       1256 KB
[  487.273324] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      94656 KB,
bdi_dirty_limit =3D      54840 KB
[  487.281646] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      94656 KB,
bdi_dirty_limit =3D      54840 KB
[  490.233678] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        716 KB
[  490.249621] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        712 KB
[  490.486277] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      88000 KB,
bdi_dirty_limit =3D      55276 KB
[  491.243332] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        836 KB
[  491.268240] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        868 KB
[  493.928206] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      95040 KB,
bdi_dirty_limit =3D      55248 KB
[  494.329925] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        692 KB
[  494.341743] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        692 KB
[  495.330591] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        864 KB
[  495.341611] [1]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D        864 KB
[  495.540560] [2]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D       1096 KB
[  495.548499] [2]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D       1096 KB
[  496.552820] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        704 KB,
bdi_dirty_limit =3D       1196 KB
[  496.560772] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        704 KB,
bdi_dirty_limit =3D       1196 KB
[  496.698932] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        640 KB,
bdi_dirty_limit =3D       1316 KB
[  496.706910] [2]:flush--8:16 : BDI_RECLAIMABLE =3D       1024 KB,
bdi_dirty_limit =3D       1316 KB
[  497.333402] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      88000 KB,
bdi_dirty_limit =3D      54784 KB
[  497.341356] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      88000 KB,
bdi_dirty_limit =3D      54784 KB
[  500.524621] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      69760 KB,
bdi_dirty_limit =3D      54980 KB
[  502.601654] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        664 KB
[  502.616538] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        664 KB
[  502.817760] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        576 KB,
bdi_dirty_limit =3D        968 KB
[  502.829866] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        832 KB,
bdi_dirty_limit =3D        964 KB
[  503.129652] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      91328 KB,
bdi_dirty_limit =3D      55028 KB
[  504.905684] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        964 KB
[  504.917666] [2]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        964 KB
[  506.422420] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      93824 KB,
bdi_dirty_limit =3D      55056 KB
[  509.545213] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      75840 KB,
bdi_dirty_limit =3D      55416 KB
[  509.635997] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        580 KB
[  509.648012] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        580 KB
[  509.662575] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      80384 KB,
bdi_dirty_limit =3D      55412 KB
[  512.607418] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      88960 KB,
bdi_dirty_limit =3D      55372 KB
[  515.643594] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        416 KB
[  515.657627] [1]:flush--8:16 : BDI_RECLAIMABLE =3D        960 KB,
bdi_dirty_limit =3D        416 KB
[  515.873800] [1]:flush-- 8:0 : BDI_RECLAIMABLE =3D      93440 KB,
bdi_dirty_limit =3D      55252 KB

As mentioned above after applying patch 'over_bground_thresh' is
returning true when reclaimable is more as compared to original
kernel.

And,
When we carefully observed the changes which we did to control the
returning condition for =E2=80=98over_bground_thresh=E2=80=99,
Even though the code changes help in avoiding unnecessary write-back
or wakeup in some scenarios.

But in one normal scenario, the changes actually results in
performance degradation.

Results for =E2=80=98dd=E2=80=99 thread on two devices:
Before applying Patch:
#> dd if=3D/dev/zero of=3D/mnt/sdb2/file1 bs=3D1048576 count=3D800 &
#> dd if=3D/dev/zero of=3D/mnt/sda6/file2 bs=3D1048576 count=3D2000 &
#>
#> 2000+0 records in
2000+0 records out
2097152000 bytes (2.0GB) copied, 77.205276 seconds, 25.9MB/s  -> USB
HDD WRITE Speed

[2]+ Done dd if=3D/dev/zero of=3D/mnt/sda6/file2 bs=3D1048576 count=3D2000
#>
#>
#> 800+0 records in
800+0 records out
838860800 bytes (800.0MB) copied, 154.528362 seconds, 5.2MB/s -> USB
Flash WRITE Speed

After applying patch:
#> dd if=3D/dev/zero of=3D/mnt/sdb2/file1 bs=3D1048576 count=3D800 &
dd if=3D/
#> dd if=3D/dev/zero of=3D/mnt/sda6/file2 bs=3D1048576 count=3D2000 &
#>
#> 2000+0 records in
2000+0 records out
2097152000 bytes (2.0GB) copied, 123.844770 seconds, 16.1MB/s ->USB
HDD WRITE Speed
800+0 records in
800+0 records out
838860800 bytes (800.0MB) copied, 141.352945 seconds, 5.7MB/s -> USB
Flash WRITE Speed

[2]+ Done dd if=3D/dev/zero of=3D/mnt/sda6/file2 bs=3D1048576 count=3D2000
[1]+ Done dd if=3D/dev/zero of=3D/mnt/sdb2/file1 bs=3D1048576 count=3D800

So, after applying our changes:
1) USB HDD Write speed dropped from 25.9 -> 16.1 MB/s
2) USB Flash Write speed increased marginally from 5.2 -> 5.7 MB/s

Normally if we have a USB Flash and HDD plugged in system. And if we
initiate the =E2=80=98dd=E2=80=99 on both the devices. Once dirty memory is=
 more than
the background threshold, flushing starts for all BDI (The write-back
for the devices will be kicked by the condition):
If (global_page_state(NR_FILE_DIRTY) +
global_page_state(NR_UNSTABLE_NFS) > background_thresh))
	return true;
As the slow device and the fast device always make sure that there is
enough DIRTY data in memory to kick write-back.
Since, USB Flash is slow, the DIRTY pages corresponding to this device
is much higher, resulting in returning =E2=80=98true=E2=80=99 everytime fro=
m
over_bground_thresh. So, even though HDD might have only few KB of
dirty data, it is also flushed immediately.
This frequent flushing of HDD data results in gradually increasing the
bdi_dirty_limit() for HDD.

But, when we introduce the change to control per BDI i.e.,
 if (global_page_state(NR_FILE_DIRTY) +
         global_page_state(NR_UNSTABLE_NFS) > background_thresh &&
         reclaimable * 2 + bdi_stat_error(bdi) * 2 > bdi_bground_thresh)

Now, in this case, when we consider the same scenario, writeback for
HDD will only be kicked only if =E2=80=98reclaimable * 2 + bdi_stat_error(b=
di)
* 2 > bdi_bground_thresh=E2=80=99
But this condition is not true a lot many number of times, so
resulting in false.

This continuous failure to start write-back for HDD actually results
in lowering the bdi_dirty_limit for HDD, in a way PAUSING the writer
thread for HDD.
This is actually resulting in less number of WRITE operations per
second for HDD. As, the =E2=80=98dd=E2=80=99 on USB HDD will be put to long=
 sleep(MAX
PAUSE) in balance_dirty_pages.

While for USB Flash, its bdi_dirty_limit is kept on increasing as it
is getting more chance to flush dirty data in over_bground_thresh. As,
bdi_reclaimable > bdi_dirty_limit is true. So, resulting more number
of WRITE operation per second for USB Flash.
>From these observations, we feel that these changes might not be
needed. Please let us know in case we are missing on any point here,
we can further check more on this.

Please share your opinion.

Thanks.
>
> Thanks,
> Fengguang
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
