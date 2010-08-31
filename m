Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A251B6B01F0
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 02:09:39 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o7V69b6F005118
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 23:09:37 -0700
Received: from gxk25 (gxk25.prod.google.com [10.202.11.25])
	by wpaz9.hot.corp.google.com with ESMTP id o7V69aeJ031977
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 23:09:36 -0700
Received: by gxk25 with SMTP id 25so3723516gxk.15
        for <linux-mm@kvack.org>; Mon, 30 Aug 2010 23:09:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100828235029.GA7071@localhost>
References: <1282963227-31867-1-git-send-email-mrubin@google.com>
 <1282963227-31867-4-git-send-email-mrubin@google.com> <20100828235029.GA7071@localhost>
From: Michael Rubin <mrubin@google.com>
Date: Mon, 30 Aug 2010 23:09:14 -0700
Message-ID: <AANLkTi=KjbfqzZsD6MOQG+4i7vHj6ZEh1_nF7DpwqeLV@mail.gmail.com>
Subject: Re: [PATCH 3/4] writeback: nr_dirtied and nr_cleaned in /proc/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 28, 2010 at 4:50 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> It's silly to have the different names nr_dirtied and pages_cleaned
> for the same item.

I agree. Will fix.

> The output format is quite different from /proc/vmstat.
> Do we really need to "Node X", ":" and "times" decorations?

Node X is based on the meminfo file but I agree it's redundant information.

> And the "_PAGES" in NR_FILE_PAGES_DIRTIED looks redundant to
> the "_page" in node_page_state(). It's a bit long to be a pleasant
> name. NR_FILE_DIRTIED/NR_CLEANED looks nicer.

Yeah. Will fix.


>> +static SYSDEV_ATTR(vmstat, S_IRUGO, node_read_vmstat, NULL);
>> +
>> =A0static ssize_t node_read_distance(struct sys_device * dev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sysdev_attribute *att=
r, char * buf)
>> =A0{
>> @@ -243,6 +255,7 @@ int register_node(struct node *node, int num, struct=
 node *parent)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sysdev_create_file(&node->sysdev, &attr_memi=
nfo);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sysdev_create_file(&node->sysdev, &attr_numa=
stat);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sysdev_create_file(&node->sysdev, &attr_dist=
ance);
>> + =A0 =A0 =A0 =A0 =A0 =A0 sysdev_create_file(&node->sysdev, &attr_vmstat=
);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan_unevictable_register_node(node);
>>
>> @@ -267,6 +280,7 @@ void unregister_node(struct node *node)
>> =A0 =A0 =A0 sysdev_remove_file(&node->sysdev, &attr_meminfo);
>> =A0 =A0 =A0 sysdev_remove_file(&node->sysdev, &attr_numastat);
>> =A0 =A0 =A0 sysdev_remove_file(&node->sysdev, &attr_distance);
>> + =A0 =A0 sysdev_remove_file(&node->sysdev, &attr_vmstat);
>>
>> =A0 =A0 =A0 scan_unevictable_unregister_node(node);
>> =A0 =A0 =A0 hugetlb_unregister_node(node); =A0 =A0 =A0 =A0 =A0/* no-op, =
if memoryless node */
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 6e6e626..d42f179 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -104,6 +104,8 @@ enum zone_stat_item {
>> =A0 =A0 =A0 NR_ISOLATED_ANON, =A0 =A0 =A0 /* Temporary isolated pages fr=
om anon lru */
>> =A0 =A0 =A0 NR_ISOLATED_FILE, =A0 =A0 =A0 /* Temporary isolated pages fr=
om file lru */
>> =A0 =A0 =A0 NR_SHMEM, =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* shmem pages (includ=
ed tmpfs/GEM pages) */
>> + =A0 =A0 NR_FILE_PAGES_DIRTIED, =A0/* number of times pages get dirtied=
 */
>> + =A0 =A0 NR_PAGES_CLEANED, =A0 =A0 =A0 /* number of times pages enter w=
riteback */
>
> How about the comments /* accumulated number of pages ... */?

OK.
May not get patch out today but will incorporate these fixes. Thank you aga=
in.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
