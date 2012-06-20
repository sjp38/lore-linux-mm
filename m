Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 9E0C66B005A
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 17:37:14 -0400 (EDT)
Received: by dakp5 with SMTP id p5so13045986dak.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 14:37:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120620140723.5c2214de.akpm@linux-foundation.org>
References: <1340184113-5028-1-git-send-email-jiang.liu@huawei.com> <20120620140723.5c2214de.akpm@linux-foundation.org>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 20 Jun 2012 17:36:53 -0400
Message-ID: <CAHGf_=p65ZNrQPK1+1b07PAdaTQRxrLL213WSxGDv=UeuDvAWA@mail.gmail.com>
Subject: Re: [Resend with ACK][PATCH] memory hotplug: fix invalid memory
 access caused by stale kswapd pointer
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Keping Chen <chenkeping@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 20, 2012 at 5:07 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 20 Jun 2012 17:21:53 +0800
> Jiang Liu <jiang.liu@huawei.com> wrote:
>
>> Function kswapd_stop() will be called to destroy the kswapd work thread
>> when all memory of a NUMA node has been offlined. But kswapd_stop() only
>> terminates the work thread without resetting NODE_DATA(nid)->kswapd to N=
ULL.
>> The stale pointer will prevent kswapd_run() from creating a new work thr=
ead
>> when adding memory to the memory-less NUMA node again. Eventually the st=
ale
>> pointer may cause invalid memory access.
>
> whoops.
>
>>
>> ...
>>
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2961,8 +2961,10 @@ void kswapd_stop(int nid)
>> =A0{
>> =A0 =A0 =A0 struct task_struct *kswapd =3D NODE_DATA(nid)->kswapd;
>>
>> - =A0 =A0 if (kswapd)
>> + =A0 =A0 if (kswapd) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 kthread_stop(kswapd);
>> + =A0 =A0 =A0 =A0 =A0 =A0 NODE_DATA(nid)->kswapd =3D NULL;
>> + =A0 =A0 }
>> =A0}
>>
>> =A0static int __init kswapd_init(void)
>
> OK.
>
> This function is full of races (ones which we'll never hit ;)) unless
> the caller provides locking. =A0It appears that lock_memory_hotplug() is
> the locking, so I propose this addition:
>
> --- a/mm/vmscan.c~memory-hotplug-fix-invalid-memory-access-caused-by-stal=
e-kswapd-pointer-fix
> +++ a/mm/vmscan.c
> @@ -2955,7 +2955,8 @@ int kswapd_run(int nid)
> =A0}
>
> =A0/*
> - * Called by memory hotplug when all memory in a node is offlined.
> + * Called by memory hotplug when all memory in a node is offlined. =A0Ca=
ller must
> + * hold lock_memory_hotplug().
> =A0*/
> =A0void kswapd_stop(int nid)
> =A0{
> --- a/include/linux/mmzone.h~memory-hotplug-fix-invalid-memory-access-cau=
sed-by-stale-kswapd-pointer-fix
> +++ a/include/linux/mmzone.h
> @@ -693,7 +693,7 @@ typedef struct pglist_data {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 range, including holes */
> =A0 =A0 =A0 =A0int node_id;
> =A0 =A0 =A0 =A0wait_queue_head_t kswapd_wait;
> - =A0 =A0 =A0 struct task_struct *kswapd;
> + =A0 =A0 =A0 struct task_struct *kswapd; =A0 =A0 /* Protected by lock_me=
mory_hotplug() */

                                                        except
"system_state =3D=3D SYSTEM_BOOTING"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
