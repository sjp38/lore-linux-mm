Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 048CA6B0037
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 18:23:18 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id t10so3720521eei.0
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 15:23:18 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.21])
        by mx.google.com with ESMTPS id i1si12623212eev.131.2013.12.05.15.23.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Dec 2013 15:23:17 -0800 (PST)
Received: from [192.168.178.21] ([85.176.188.62]) by mail.gmx.com (mrgmx102)
 with ESMTPSA (Nemesis) id 0MP1PX-1VuVYi0hh1-006Kdu for <linux-mm@kvack.org>;
 Fri, 06 Dec 2013 00:23:17 +0100
Message-ID: <52A10AE0.1020607@gmx.de>
Date: Fri, 06 Dec 2013 00:23:12 +0100
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: why does index in truncate_inode_pages_range() grows so much
 ?
References: <529217CD.1000204@gmx.de> <20131203140214.GB31128@quack.suse.cz> <529E3450.9000700@gmx.de> <20131203230058.GA24037@quack.suse.cz>
In-Reply-To: <20131203230058.GA24037@quack.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: UML devel <user-mode-linux-devel@lists.sourceforge.net>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 12/04/2013 12:00 AM, Jan Kara wrote:
> On Tue 03-12-13 20:43:12, Toralf FA?rster wrote:
>> On 12/03/2013 03:02 PM, Jan Kara wrote:
>>> On Sun 24-11-13 16:14:21, Toralf FA?rster wrote:
>>>> At a 32 bit guest UML with current kernel git tree I putted a printk
>>>> into that function :
>>>>
>>>> void truncate_inode_pages_range(struct address_space *mapping,
>>>>                                 loff_t lstart, loff_t lend)
>>>> {
>>>> ...
>>>>
>>>>
>>>>                 cond_resched();
>>>>                 index++;
>>>> 		printk ("            <------------
>>>>
>>>>
>>>>
>>>>
>>>> and got (while fuzzying the UML guest with trinity) this output in the
>>>> UML guest:
>>>>
>>>>
>>>> Nov 24 12:06:53 trinity kernel: index:42 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:43 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:5 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:1 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:1 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:1035468800 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:1 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:1 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:1 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:16 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:1 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:4 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:2 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:1 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:4184867847 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:1 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:3 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:1727 end:4294967295
>>>> Nov 24 12:06:53 trinity kernel: index:1 end:4294967295
>>>>
>>>>
>>>> I'm wondering if index is expected to become sometimes so big.
>>>   No, I wouldn't expect such huge indices. OTOH with fuzzing there could be
>>> some valid explanations. Could you move the printk before
>>> pagevec_release(), print also 'start' variable and in case 'index' is
>>> suspiciously large, print also 'i' and some info about the page pvec[i]
>>> page (page->index, page->flags, page->mapping->host->i_sb->s_id,
>>> page->mapping->host->i_ino)?
>>>
>>> 								Honza
>>>
>>
>> Well, with this diff against current git tree of Linus :
>>
>>
>> diff --git a/mm/truncate.c b/mm/truncate.c
>> index 353b683..41eecba 100644
>> --- a/mm/truncate.c
>> +++ b/mm/truncate.c
>> @@ -244,6 +244,11 @@ void truncate_inode_pages_range(struct address_space *mapping,
>>                 for (i = 0; i < pagevec_count(&pvec); i++) {
>>                         struct page *page = pvec.pages[i];
>>
>> +                       if (index > 1000)       {
>> +                               printk (" page->index:%ld  ->flags:%lu  ->s_id:%s  ->i_no:%lu \n",
>> +                                       page->index , page->flags, page->mapping->host->i_sb->s_id, page->mapping->host->i_ino);
>> +                       }
>> +
>>                         /* We rely upon deletion not changing page->index */
>>                         index = page->index;
>>                         if (index >= end)
>> @@ -259,6 +264,9 @@ void truncate_inode_pages_range(struct address_space *mapping,
>>                         truncate_inode_page(mapping, page);
>>                         unlock_page(page);
>>                 }
>> +               if (index > 1000)       {
>> +                       printk (" index:%lu  i:%i  start:%lu \n", index, i, start);
>> +               }
>>                 pagevec_release(&pvec);
>>                 mem_cgroup_uncharge_end();
>>                 cond_resched();
>>
>>
>> I do get :
>   Especially these look really weird:
>> Dec  3 20:25:04 trinity kernel: page->index:1812025924  ->flags:40  ->s_id:ubda  ->i_no:88433 
>   It means we have a PG_uptodate | PG_lru page on a normal filesystem (can
> you check what file has inode number 88433 please? What fs is on udba?) with
> rather weird index. Adding linux-mm to CC, maybe someone has an idea...
> 
> 								Honza
> 

ubda is an User mode linux image (32it stable Gentoo Linux) :

$ file ~/virtual/uml/trinity
/home/tfoerste/virtual/uml/trinity: Linux rev 1.0 ext4 filesystem data,
UUID=d0389c56-7a1d-4545-9743-2abc37468fb5, volume name "stable"
(extents) (large files) (huge files)

The inode belongs to (just one of 200 victim files/directories I do
create before each trinity run):


# ls -il /tmp/victims/v1/v2/f51
88433 -rw-r--r-- 1 tfoerste users 0 Dec  3 20:40 /tmp/victims/v1/v2/f51

# file /tmp/victims/v1/v2/f51
/tmp/victims/v1/v2/f51: empty


>> Dec  3 20:18:15 trinity kernel: VFS: Warning: trinity-child1 using old stat() call. Recompile your binary.
>> Dec  3 20:18:15 trinity kernel: VFS: Warning: trinity-child1 using old stat() call. Recompile your binary.
>> Dec  3 20:18:15 trinity kernel: VFS: Warning: trinity-child1 using old stat() call. Recompile your binary.
>> Dec  3 20:18:15 trinity kernel: VFS: Warning: trinity-child0 using old stat() call. Recompile your binary.
>> Dec  3 20:18:15 trinity kernel: VFS: Warning: trinity-child0 using old stat() call. Recompile your binary.
>> Dec  3 20:18:16 trinity kernel: warning: process `trinity-child0' used the deprecated sysctl system call with 
>> Dec  3 20:19:20 trinity kernel: index:104855155  i:2  start:0 
>> Dec  3 20:19:26 trinity sshd[1270]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:19:31 trinity sshd[1497]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:19:31 trinity kernel: type=1006 audit(1386098371.701:5): pid=1497 uid=0 old auid=4294967295 new auid=1000 old ses=4294967295 new ses=4 res=1
>> Dec  3 20:19:31 trinity su[1501]: Successful su for root by root
>> Dec  3 20:19:31 trinity su[1501]: + ??? root:root
>> Dec  3 20:19:31 trinity su[1501]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:19:31 trinity su[1501]: pam_unix(su:session): session closed for user root
>> Dec  3 20:19:31 trinity tfoerste: M=/tmp
>> Dec  3 20:19:32 trinity kernel: index:1069550501  i:5  start:0 
>> Dec  3 20:19:32 trinity kernel: index:3710009344  i:1  start:0 
>> Dec  3 20:19:32 trinity kernel: index:262454  i:2  start:0 
>> Dec  3 20:20:01 trinity cron[1720]: (root) CMD (test -x /usr/sbin/run-crons && /usr/sbin/run-crons)
>> Dec  3 20:20:01 trinity run-crons[1731]: (root) CMD (/etc/cron.daily/logrotate)
>> Dec  3 20:20:02 trinity run-crons[1736]: (root) CMD (/etc/cron.daily/makewhatis)
>> Dec  3 20:20:05 trinity run-crons[1829]: (root) CMD (/etc/cron.daily/mlocate)
>> Dec  3 20:21:21 trinity sshd[1497]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:21:26 trinity sshd[1854]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:21:27 trinity kernel: type=1006 audit(1386098486.801:6): pid=1854 uid=0 old auid=4294967295 new auid=1000 old ses=4294967295 new ses=5 res=1
>> Dec  3 20:21:26 trinity su[1858]: Successful su for root by root
>> Dec  3 20:21:26 trinity su[1858]: + ??? root:root
>> Dec  3 20:21:26 trinity su[1858]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:21:27 trinity su[1858]: pam_unix(su:session): session closed for user root
>> Dec  3 20:21:27 trinity tfoerste: M=/tmp
>> Dec  3 20:21:27 trinity kernel: index:4095  i:1  start:0 
>> Dec  3 20:21:27 trinity kernel: index:262143  i:1  start:0 
>> Dec  3 20:21:27 trinity kernel: index:2651  i:2  start:0 
>> Dec  3 20:21:27 trinity kernel: index:320986  i:2  start:0 
>> Dec  3 20:21:27 trinity kernel: index:4252242242  i:1  start:0 
>> Dec  3 20:21:27 trinity kernel: index:2502  i:1  start:0 
>> Dec  3 20:21:27 trinity kernel: index:2097151  i:2  start:0 
>> Dec  3 20:22:42 trinity sshd[1854]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:22:47 trinity sshd[2083]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:22:47 trinity kernel: type=1006 audit(1386098567.721:7): pid=2083 uid=0 old auid=4294967295 new auid=1000 old ses=4294967295 new ses=6 res=1
>> Dec  3 20:22:47 trinity su[2087]: Successful su for root by root
>> Dec  3 20:22:47 trinity su[2087]: + ??? root:root
>> Dec  3 20:22:47 trinity su[2087]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:22:48 trinity kernel: index:2097151  i:5  start:0 
>> Dec  3 20:22:48 trinity kernel: index:2426404863  i:1  start:0 
>> Dec  3 20:22:47 trinity su[2087]: pam_unix(su:session): session closed for user root
>> Dec  3 20:22:47 trinity tfoerste: M=/tmp
>> Dec  3 20:22:52 trinity kernel: index:4294005092  i:1  start:1 
>> Dec  3 20:23:23 trinity kernel: index:1572852  i:1  start:1 
>> Dec  3 20:24:00 trinity sshd[2083]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:24:05 trinity sshd[2313]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:24:05 trinity kernel: type=1006 audit(1386098645.461:8): pid=2313 uid=0 old auid=4294967295 new auid=1000 old ses=4294967295 new ses=7 res=1
>> Dec  3 20:24:05 trinity su[2317]: Successful su for root by root
>> Dec  3 20:24:05 trinity su[2317]: + ??? root:root
>> Dec  3 20:24:05 trinity su[2317]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:24:05 trinity su[2317]: pam_unix(su:session): session closed for user root
>> Dec  3 20:24:05 trinity tfoerste: M=/tmp
>> Dec  3 20:24:06 trinity kernel: index:4059  i:1  start:0 
>> Dec  3 20:24:06 trinity kernel: index:1038123009  i:1  start:0 
>> Dec  3 20:24:06 trinity kernel: page->index:319388983  ->flags:40  ->s_id:ubda  ->i_no:88523 
>> Dec  3 20:24:06 trinity kernel: index:319388983  i:3  start:0 
>> Dec  3 20:24:06 trinity kernel: index:4063  i:1  start:0 
>> Dec  3 20:24:06 trinity kernel: index:262058  i:2  start:0 
>> Dec  3 20:24:43 trinity kernel: index:2045  i:1  start:0 
>> Dec  3 20:24:45 trinity kernel: index:331505  i:1  start:1 
>> Dec  3 20:24:58 trinity sshd[2313]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:25:03 trinity sshd[2542]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:25:03 trinity kernel: type=1006 audit(1386098703.331:9): pid=2542 uid=0 old auid=4294967295 new auid=1000 old ses=4294967295 new ses=8 res=1
>> Dec  3 20:25:03 trinity su[2546]: Successful su for root by root
>> Dec  3 20:25:03 trinity su[2546]: + ??? root:root
>> Dec  3 20:25:03 trinity su[2546]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:25:03 trinity su[2546]: pam_unix(su:session): session closed for user root
>> Dec  3 20:25:03 trinity tfoerste: M=/tmp
>> Dec  3 20:25:04 trinity kernel: index:685130  i:1  start:0 
>> Dec  3 20:25:04 trinity kernel: index:4294964224  i:2  start:0 
>> Dec  3 20:25:04 trinity kernel: index:2166337610  i:4  start:0 
>> Dec  3 20:25:04 trinity kernel: index:1934  i:2  start:0 
>> Dec  3 20:25:04 trinity kernel: page->index:1812025924  ->flags:40  ->s_id:ubda  ->i_no:88433 
>> Dec  3 20:25:04 trinity kernel: index:1812025924  i:3  start:0 
>> Dec  3 20:25:49 trinity sshd[2542]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:25:54 trinity sshd[2774]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:25:55 trinity kernel: type=1006 audit(1386098754.991:10): pid=2774 uid=0 old auid=4294967295 new auid=1000 old ses=4294967295 new ses=9 res=1
>> Dec  3 20:25:54 trinity su[2778]: Successful su for root by root
>> Dec  3 20:25:54 trinity su[2778]: + ??? root:root
>> Dec  3 20:25:54 trinity su[2778]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:25:55 trinity su[2778]: pam_unix(su:session): session closed for user root
>> Dec  3 20:25:55 trinity tfoerste: M=/tmp
>> Dec  3 20:25:55 trinity kernel: index:132644872  i:2  start:0 
>> Dec  3 20:25:55 trinity kernel: index:2326  i:7  start:0 
>> Dec  3 20:25:55 trinity kernel: index:466537  i:5  start:0 
>> Dec  3 20:27:05 trinity kernel: index:4028626354  i:4  start:2 
>> Dec  3 20:27:11 trinity kernel: index:1239957504  i:2  start:0 
>> Dec  3 20:27:15 trinity sshd[2774]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:27:20 trinity sshd[3001]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:27:21 trinity kernel: type=1006 audit(1386098840.841:11): pid=3001 uid=0 old auid=4294967295 new auid=1000 old ses=4294967295 new ses=10 res=1
>> Dec  3 20:27:20 trinity su[3005]: Successful su for root by root
>> Dec  3 20:27:20 trinity su[3005]: + ??? root:root
>> Dec  3 20:27:20 trinity su[3005]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:27:20 trinity su[3005]: pam_unix(su:session): session closed for user root
>> Dec  3 20:27:21 trinity tfoerste: M=/tmp
>> Dec  3 20:27:21 trinity kernel: index:3545  i:1  start:0 
>> Dec  3 20:27:21 trinity kernel: index:259826  i:1  start:0 
>> Dec  3 20:29:40 trinity sshd[3001]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:29:45 trinity kernel: type=1006 audit(1386098985.591:12): pid=3234 uid=0 old auid=4294967295 new auid=1000 old ses=4294967295 new ses=11 res=1
>> Dec  3 20:29:45 trinity sshd[3234]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:29:45 trinity su[3238]: Successful su for root by root
>> Dec  3 20:29:45 trinity su[3238]: + ??? root:root
>> Dec  3 20:29:45 trinity su[3238]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:29:45 trinity su[3238]: pam_unix(su:session): session closed for user root
>> Dec  3 20:29:45 trinity tfoerste: M=/tmp
>> Dec  3 20:29:47 trinity kernel: index:4079  i:1  start:0 
>> Dec  3 20:29:47 trinity kernel: index:2316  i:1  start:0 
>> Dec  3 20:29:47 trinity kernel: index:3065970688  i:1  start:0 
>> Dec  3 20:29:47 trinity kernel: index:3686793217  i:1  start:0 
>> Dec  3 20:29:47 trinity kernel: index:4294967285  i:6  start:0 
>> Dec  3 20:29:47 trinity kernel: index:16384  i:1  start:0 
>> Dec  3 20:30:01 trinity cron[3455]: (root) CMD (test -x /usr/sbin/run-crons && /usr/sbin/run-crons)
>> Dec  3 20:30:57 trinity kernel: index:2047  i:1  start:0 
>> Dec  3 20:30:57 trinity kernel: index:25313287  i:1  start:0 
>> Dec  3 20:30:57 trinity kernel: index:1048568  i:1  start:0 
>> Dec  3 20:31:01 trinity sshd[3234]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:31:06 trinity sshd[3476]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:31:06 trinity su[3480]: Successful su for root by root
>> Dec  3 20:31:06 trinity su[3480]: + ??? root:root
>> Dec  3 20:31:06 trinity su[3480]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:31:06 trinity su[3480]: pam_unix(su:session): session closed for user root
>> Dec  3 20:31:06 trinity tfoerste: M=/tmp
>> Dec  3 20:31:11 trinity kernel: page->index:1165604  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165605  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165606  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165607  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165608  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165609  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165610  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165610  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165611  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165612  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165613  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165614  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165615  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165616  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165617  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165618  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165619  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165620  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165621  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165622  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165623  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165624  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165624  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165625  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165626  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165627  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165628  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165629  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165630  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165631  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165632  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165633  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165634  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165635  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165636  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165637  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165638  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165638  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165639  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165640  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165641  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165642  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165643  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165644  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165645  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165646  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165647  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165648  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165649  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165650  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165651  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165652  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165652  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165653  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165654  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165655  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165656  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165657  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165658  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165659  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165660  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165661  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165662  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165663  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165664  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165665  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165666  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165666  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165667  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165668  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165669  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165670  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165671  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165672  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165673  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165674  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165675  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165676  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165677  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165678  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165679  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165680  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165680  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165681  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165682  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165683  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165684  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165685  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165686  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165687  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165688  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165689  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165690  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165691  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165692  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165693  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165694  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165694  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165695  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165696  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165697  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165698  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165699  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165700  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165701  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165702  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165703  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165704  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165705  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165706  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165707  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165708  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165708  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165709  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165710  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165711  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165712  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165713  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165714  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165715  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165716  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165717  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165718  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165719  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165720  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165721  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165722  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165722  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165723  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165724  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165725  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165726  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165727  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165728  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165729  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165730  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165731  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165732  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165733  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165734  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165735  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165736  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165736  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165737  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165738  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165739  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165740  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165741  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165742  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165743  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165744  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165745  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165746  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165747  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165748  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165749  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165750  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165750  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165751  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165752  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165753  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165754  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165755  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165756  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165757  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165758  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165759  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165760  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165761  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165762  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165763  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165764  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165764  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165765  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165766  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165767  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165768  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165769  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165770  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165771  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165772  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165773  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165774  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165775  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165776  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165777  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165778  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165778  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165779  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165780  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165781  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165782  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165783  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165784  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165785  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165786  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165787  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165788  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165789  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165790  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165791  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165792  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165792  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165793  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165794  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165795  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165796  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165797  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165798  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165799  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165800  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165801  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165802  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165803  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165804  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165805  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165806  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165806  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165807  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165808  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165809  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165810  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165811  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165812  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165813  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165814  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165815  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165816  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165817  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165818  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165819  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165820  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165820  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165821  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165822  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165823  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165824  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165825  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165826  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165827  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165828  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165829  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165830  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165831  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165832  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165833  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165834  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165834  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165835  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165836  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165837  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165838  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165839  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165840  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165841  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165842  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165843  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165844  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165845  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165846  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165847  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165848  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165848  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165849  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165850  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165851  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165852  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165853  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165854  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165855  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165856  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165857  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165858  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165859  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165860  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165861  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165862  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165862  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165863  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165864  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165865  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165866  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165867  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165868  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165869  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165870  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165871  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165872  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165873  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165874  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165875  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165876  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165876  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165877  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165878  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165879  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165880  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165881  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165882  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165883  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165884  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165885  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165886  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165887  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165888  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165889  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165890  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165890  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165891  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165892  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165893  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165894  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165895  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165896  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165897  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165898  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165899  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165900  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165901  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165902  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165903  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165904  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165904  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165905  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165906  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165907  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165908  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165909  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165910  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165911  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165912  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165913  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165914  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165915  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165916  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165917  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165918  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165918  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165919  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165920  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165921  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165922  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165923  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165924  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165925  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165926  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165927  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165928  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165929  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165930  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165931  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165932  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165932  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165933  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165934  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165935  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165936  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165937  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165938  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165939  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165940  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165941  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165942  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165943  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165944  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165945  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165946  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165946  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165947  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165948  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165949  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165950  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165951  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165952  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165953  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165954  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165955  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165956  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165957  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165958  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165959  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165960  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165960  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165961  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165962  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165963  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165964  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165965  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165966  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165967  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165968  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165969  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165970  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165971  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165972  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165973  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165974  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165974  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165975  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165976  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165977  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165978  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165979  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165980  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165981  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165982  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165983  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165984  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165985  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165986  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165987  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165988  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1165988  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1165989  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165990  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165991  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165992  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165993  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165994  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165995  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165996  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165997  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165998  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1165999  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166000  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166001  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166002  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1166002  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1166003  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166004  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166005  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166006  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166007  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166008  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166009  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166010  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166011  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166012  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166013  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166014  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166015  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166016  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1166016  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1166017  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166018  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166019  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166020  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166021  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166022  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166023  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166024  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166025  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166026  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166027  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166028  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166029  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166030  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1166030  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1166031  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166032  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166033  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166034  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166035  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166036  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166037  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166038  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166039  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166040  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166041  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166042  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166043  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166044  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1166044  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1166045  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166046  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166047  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166048  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166049  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166050  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166051  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166052  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166053  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166054  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166055  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166056  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166057  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166058  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: index:1166058  i:14  start:0 
>> Dec  3 20:31:11 trinity kernel: page->index:1166059  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:31:11 trinity kernel: page->index:1166060  ->flags:40  ->s_id:ubda  ->i_no:88357 
>> Dec  3 20:32:20 trinity sshd[3476]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:32:25 trinity sshd[3704]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:32:25 trinity su[3708]: Successful su for root by root
>> Dec  3 20:32:25 trinity su[3708]: + ??? root:root
>> Dec  3 20:32:25 trinity su[3708]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:32:25 trinity su[3708]: pam_unix(su:session): session closed for user root
>> Dec  3 20:32:25 trinity tfoerste: M=/tmp
>> Dec  3 20:33:11 trinity sshd[3704]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:33:16 trinity sshd[3928]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:33:16 trinity su[3932]: Successful su for root by root
>> Dec  3 20:33:16 trinity su[3932]: + ??? root:root
>> Dec  3 20:33:16 trinity su[3932]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:33:16 trinity su[3932]: pam_unix(su:session): session closed for user root
>> Dec  3 20:33:16 trinity tfoerste: M=/tmp
>> Dec  3 20:35:33 trinity sshd[3928]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:35:38 trinity sshd[4163]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:35:38 trinity su[4167]: Successful su for root by root
>> Dec  3 20:35:38 trinity su[4167]: + ??? root:root
>> Dec  3 20:35:38 trinity su[4167]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:35:38 trinity su[4167]: pam_unix(su:session): session closed for user root
>> Dec  3 20:35:38 trinity tfoerste: M=/tmp
>> Dec  3 20:37:52 trinity sshd[4163]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:37:58 trinity sshd[4395]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:37:58 trinity su[4399]: Successful su for root by root
>> Dec  3 20:37:58 trinity su[4399]: + ??? root:root
>> Dec  3 20:37:58 trinity su[4399]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:37:58 trinity su[4399]: pam_unix(su:session): session closed for user root
>> Dec  3 20:37:58 trinity tfoerste: M=/tmp
>> Dec  3 20:38:14 trinity sshd[4395]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:38:19 trinity sshd[4620]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:38:19 trinity su[4624]: Successful su for root by root
>> Dec  3 20:38:19 trinity su[4624]: + ??? root:root
>> Dec  3 20:38:19 trinity su[4624]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:38:19 trinity su[4624]: pam_unix(su:session): session closed for user root
>> Dec  3 20:38:19 trinity tfoerste: M=/tmp
>> Dec  3 20:40:01 trinity cron[4847]: (root) CMD (test -x /usr/sbin/run-crons && /usr/sbin/run-crons)
>> Dec  3 20:40:04 trinity sshd[4620]: pam_unix(sshd:session): session closed for user tfoerste
>> Dec  3 20:40:09 trinity sshd[4860]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
>> Dec  3 20:40:09 trinity su[4864]: Successful su for root by root
>> Dec  3 20:40:09 trinity su[4864]: + ??? root:root
>> Dec  3 20:40:09 trinity su[4864]: pam_unix(su:session): session opened for user root by (uid=0)
>> Dec  3 20:40:09 trinity su[4864]: pam_unix(su:session): session closed for user root
>> Dec  3 20:40:09 trinity tfoerste: M=/tmp
>> ^CKilled by signal 2.
>> tfoerste@n22 ~/devel/linux $ ssh root@trinity "halt; exit"
>>
>>
>> -- 
>> MfG/Sincerely
>> Toralf FA?rster
>> pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3


-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
