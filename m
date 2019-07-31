Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11C1DC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:09:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93161216C8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:09:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="rrVgDTvL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93161216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BE228E0012; Wed, 31 Jul 2019 12:09:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16E258E0006; Wed, 31 Jul 2019 12:09:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 036988E0012; Wed, 31 Jul 2019 12:09:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D66408E0006
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:09:10 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id l16so55222532qtq.16
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:09:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=22X7eV+11aclgxpUtL0UhMPqWeii16OSPDsnBbdbXNQ=;
        b=kIqG65b88cqT3rvMBFmFPpZt7L4wdTS+pXj4pfVhMR2zQM2r4dKBeN4/fIP0bAHSyD
         xbM7oyUPPyKpMdxGCoxjVLaorFj5lMUZjq0w53g1ulbyr/wayz49NUOu0yHRFH2VU8sO
         68miGemjD1Ev4eUHa3/zJJpxG6OxRcYrF9dux7iIA4++VyJvy7kCS/miBwEEA94XtcXu
         4jdzcRbrA6rs+A3MAecJ5mjuKvxcUqmI1/4EF0qNKVm19hhKyukcphOVj3fGgGgGW7tC
         OzL86jq3LfnjeQpxd5PaIZOqZhdy+3NAcDbMRQgdC5PmpzEMRVVTe7x8IiM1p0qjWBGP
         Hk3Q==
X-Gm-Message-State: APjAAAXEfDbPBadgYC9lre7ldi2d/lfkLW0arKrem0zsFPVecGayMP0S
	3fqYqDDXfzO8HK4WsLBm71z/vR8U58LP7oXJIVd4ALeNXQ+5YwcQG2y3Nc4E/WOKpKDJsx2fSj9
	sgyBveNb7ZmpJ2DQU9DHj4od93dAX/5FSKB8oSeqhpBh1bG2BOoSPJ+jHmmLuH4ffHw==
X-Received: by 2002:a37:8a81:: with SMTP id m123mr79960597qkd.360.1564589350568;
        Wed, 31 Jul 2019 09:09:10 -0700 (PDT)
X-Received: by 2002:a37:8a81:: with SMTP id m123mr79960529qkd.360.1564589349638;
        Wed, 31 Jul 2019 09:09:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564589349; cv=none;
        d=google.com; s=arc-20160816;
        b=HqxHWlkwaWRpLQ3RVWRjjY6cmPq+1j9lV8gr6HzZCmvcb7MUQoDQXCmdsmArwuvn27
         gBS8iAEqEANhE3lu4Kf51SazCgYAXUl7IGixvPyNo6pzZfljTUzdadEyfQc+Gkzz7kg8
         YUp9WF3raVQkHZu93VFZYo/vpTmmVl4D/vndqHncccle8o56zQAc4YIhmJhrwts9K+Px
         LM8IOkgbaG3umwONe2q3Vmy6RM3MacVr6hwpKVe/n56kLsDauG76sgw34ouKjfC6cYNu
         xzNphw9zBFB0GseLKmHqzTncrxujRnLFS9ABYiR00Idc+27NDpULj0uFvWkleSep5Xsd
         rliQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=22X7eV+11aclgxpUtL0UhMPqWeii16OSPDsnBbdbXNQ=;
        b=KVMNzl0HHU0trqEBGj/AjAecKQPzD1KHKHlaJEB2mEE1NJlYk9aFCvILQ4+q7bNi4z
         q2NSqafVe/dfGK7IuIqMURNeuFCgc9sdcThYzoPDTyNrE6eN2rskuMFn5jpqLbrkyG7p
         7tuxX82y37qw1uz5V4pabIM5gZ9zC5r+mkz0EqxSOLXsY0NokmAmiFCX1RNb0evOOIly
         cWjM4pRCKS6M11fWX5bLiFRU1uc3kHb0The0D/gGcToqVKswJjdEcRBAXC73dxwLfFp7
         ZQwpyeBH1FzWDYcYht40hQgTK6LWNOhkxkDVqNHhowin4YYMn0rHHoulvbpa8lH5ywF9
         Y/Ww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=rrVgDTvL;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s58sor58151440qvs.14.2019.07.31.09.09.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 09:09:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=rrVgDTvL;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=22X7eV+11aclgxpUtL0UhMPqWeii16OSPDsnBbdbXNQ=;
        b=rrVgDTvLl81D0HuifNAFmvvicRivWJgZTTCdNscp61dqlaT5tJYtqtrEmD3cEe9uaW
         PQ7I5ku04o6H07JXUWDTExWeYaWDMD57t808dNjiYiLlDZnOVU/h4XPHG7o+rHHDsJqy
         qn+olM7tgsdXDpJOUkBC8r9VUvQNIKDcW+OL6xSuXZDGJ5evSj9geuN1utalEejNzb3b
         RdWujcDkO7udcXB0iqwfN+B1YdTETbGsrS5TjirtnC1PVIqHM6lszUa0sZGtb3yeahrt
         vwTh9Jpnnz9AXAEUzKq1M7IxdYHYXjgEy+gGfvL1sN6sk15NGnQqa2NiqX5vVyI4QZnv
         CtSQ==
X-Google-Smtp-Source: APXvYqwmgTYlz6sqfBxfCQ7lIo847w+jJbfUTtO6CWA9Kevt3NtWJi5zAtjJ1BNkaus8CvezlDAfnA==
X-Received: by 2002:a0c:b521:: with SMTP id d33mr88857377qve.239.1564589349073;
        Wed, 31 Jul 2019 09:09:09 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id l123sm28914131qkc.9.2019.07.31.09.09.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 09:09:08 -0700 (PDT)
Message-ID: <1564589346.11067.38.camel@lca.pw>
Subject: Re: "mm: account nr_isolated_xxx in [isolate|putback]_lru_page"
 breaks OOM with swap
From: Qian Cai <cai@lca.pw>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner
	 <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Date: Wed, 31 Jul 2019 12:09:06 -0400
In-Reply-To: <20190731053444.GA155569@google.com>
References: <1564503928.11067.32.camel@lca.pw>
	 <20190731053444.GA155569@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-31 at 14:34 +0900, Minchan Kim wrote:
> On Tue, Jul 30, 2019 at 12:25:28PM -0400, Qian Cai wrote:
> > OOM workloads with swapping is unable to recover with linux-next since next-
> > 20190729 due to the commit "mm: account nr_isolated_xxx in
> > [isolate|putback]_lru_page" breaks OOM with swap" [1]
> > 
> > [1] https://lore.kernel.org/linux-mm/20190726023435.214162-4-minchan@kernel.
> > org/
> > T/#mdcd03bcb4746f2f23e6f508c205943726aee8355
> > 
> > For example, LTP oom01 test case is stuck for hours, while it finishes in a
> > few
> > minutes here after reverted the above commit. Sometimes, it prints those
> > message
> > while hanging.
> > 
> > [  509.983393][  T711] INFO: task oom01:5331 blocked for more than 122
> > seconds.
> > [  509.983431][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
> > [  509.983447][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> > disables this message.
> > [  509.983477][  T711] oom01           D24656  5331   5157 0x00040000
> > [  509.983513][  T711] Call Trace:
> > [  509.983538][  T711] [c00020037d00f880] [0000000000000008] 0x8
> > (unreliable)
> > [  509.983583][  T711] [c00020037d00fa60] [c000000000023724]
> > __switch_to+0x3a4/0x520
> > [  509.983615][  T711] [c00020037d00fad0] [c0000000008d17bc]
> > __schedule+0x2fc/0x950
> > [  509.983647][  T711] [c00020037d00fba0] [c0000000008d1e68]
> > schedule+0x58/0x150
> > [  509.983684][  T711] [c00020037d00fbd0] [c0000000008d7614]
> > rwsem_down_read_slowpath+0x4b4/0x630
> > [  509.983727][  T711] [c00020037d00fc90] [c0000000008d7dfc]
> > down_read+0x12c/0x240
> > [  509.983758][  T711] [c00020037d00fd20] [c00000000005fb28]
> > __do_page_fault+0x6f8/0xee0
> > [  509.983801][  T711] [c00020037d00fe20] [c00000000000a364]
> > handle_page_fault+0x18/0x38
> 
> Thanks for the testing! No surprise the patch make some bugs because
> it's rather tricky.
> 
> Could you test this patch?

It does help the situation a bit, but the recover speed is still way slower than
just reverting the commit "mm: account nr_isolated_xxx in
[isolate|putback]_lru_page". For example, on this powerpc system, it used to
take 4-min to finish oom01 while now still take 13-min.

The oom02 (testing NUMA mempolicy) takes even longer and I gave up after 26-min
with several hang tasks below.

[ 7881.086027][  T723]       Tainted: G        W         5.3.0-rc2-next-
20190731+ #4
[ 7881.086045][  T723] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 7881.086064][  T723] oom02           D26080 112911 112776 0x00040000
[ 7881.086100][  T723] Call Trace:
[ 7881.086113][  T723] [c00000185deef880] [0000000000000008] 0x8 (unreliable)
[ 7881.086142][  T723] [c00000185deefa60] [c0000000000236e4]
__switch_to+0x3a4/0x520
[ 7881.086182][  T723] [c00000185deefad0] [c0000000008d045c]
__schedule+0x2fc/0x950
[ 7881.086225][  T723] [c00000185deefba0] [c0000000008d0b08] schedule+0x58/0x150
[ 7881.086279][  T723] [c00000185deefbd0] [c0000000008d6284]
rwsem_down_read_slowpath+0x4b4/0x630
[ 7881.086311][  T723] [c00000185deefc90] [c0000000008d6a6c]
down_read+0x12c/0x240
[ 7881.086340][  T723] [c00000185deefd20] [c00000000005fa34]
__do_page_fault+0x6e4/0xeb0
[ 7881.086406][  T723] [c00000185deefe20] [c00000000000a364]
handle_page_fault+0x18/0x38
[ 7881.086435][  T723] INFO: task oom02:112913 blocked for more than 368
seconds.
[ 7881.086472][  T723]       Tainted: G        W         5.3.0-rc2-next-
20190731+ #4
[ 7881.086509][  T723] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 7881.086551][  T723] oom02           D26832 112913 112776 0x00040000
[ 7881.086583][  T723] Call Trace:
[ 7881.086596][  T723] [c000201c450af890] [0000000000000008] 0x8 (unreliable)
[ 7881.086636][  T723] [c000201c450afa70] [c0000000000236e4]
__switch_to+0x3a4/0x520
[ 7881.086679][  T723] [c000201c450afae0] [c0000000008d045c]
__schedule+0x2fc/0x950
[ 7881.086720][  T723] [c000201c450afbb0] [c0000000008d0b08] schedule+0x58/0x150
[ 7881.086762][  T723] [c000201c450afbe0] [c0000000008d6284]
rwsem_down_read_slowpath+0x4b4/0x630
[ 7881.086818][  T723] [c000201c450afca0] [c0000000008d6a6c]
down_read+0x12c/0x240
[ 7881.086860][  T723] [c000201c450afd30] [c00000000035534c]
__mm_populate+0x12c/0x200
[ 7881.086902][  T723] [c000201c450afda0] [c00000000036a65c] do_mlock+0xec/0x2f0
[ 7881.086955][  T723] [c000201c450afe00] [c00000000036aa24] sys_mlock+0x24/0x40
[ 7881.086987][  T723] [c000201c450afe20] [c00000000000ae08]
system_call+0x5c/0x70
[ 7881.087025][  T723] 
[ 7881.087025][  T723] Showing all locks held in the system:
[ 7881.087065][  T723] 3 locks held by systemd/1:
[ 7881.087111][  T723]  #0: 000000002f8cb0d9 (&ep->mtx){....}, at:
ep_scan_ready_list+0x2a8/0x2d0
[ 7881.087159][  T723]  #1: 000000004e0b13a9 (&mm->mmap_sem){....}, at:
__do_page_fault+0x184/0xeb0
[ 7881.087209][  T723]  #2: 000000006dafe1e3 (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[ 7881.087292][  T723] 1 lock held by khungtaskd/723:
[ 7881.087327][  T723]  #0: 00000000e4addba8 (rcu_read_lock){....}, at:
debug_show_all_locks+0x50/0x170
[ 7881.087388][  T723] 1 lock held by oom02/112907:
[ 7881.087411][  T723]  #0: 000000003463bed2 (&mm->mmap_sem){....}, at:
vm_mmap_pgoff+0x8c/0x160
[ 7881.087487][  T723] 1 lock held by oom02/112908:
[ 7881.087522][  T723]  #0: 000000003463bed2 (&mm->mmap_sem){....}, at:
vm_mmap_pgoff+0x8c/0x160
[ 7881.087566][  T723] 1 lock held by oom02/112909:
[ 7881.087591][  T723]  #0: 000000003463bed2 (&mm->mmap_sem){....}, at:
vm_mmap_pgoff+0x8c/0x160
[ 7881.087627][  T723] 1 lock held by oom02/112910:
[ 7881.087662][  T723]  #0: 000000003463bed2 (&mm->mmap_sem){....}, at:
vm_mmap_pgoff+0x8c/0x160
[ 7881.087707][  T723] 1 lock held by oom02/112911:
[ 7881.087743][  T723]  #0: 000000003463bed2 (&mm->mmap_sem){....}, at:
__do_page_fault+0x6e4/0xeb0
[ 7881.087793][  T723] 1 lock held by oom02/112912:
[ 7881.087827][  T723]  #0: 000000003463bed2 (&mm->mmap_sem){....}, at:
vm_mmap_pgoff+0x8c/0x160
[ 7881.087872][  T723] 1 lock held by oom02/112913:
[ 7881.087897][  T723]  #0: 000000003463bed2 (&mm->mmap_sem){....}, at:
__mm_populate+0x12c/0x200
[ 7881.087943][  T723] 1 lock held by oom02/112914:
[ 7881.087979][  T723]  #0: 000000003463bed2 (&mm->mmap_sem){....}, at:
vm_mmap_pgoff+0x8c/0x160
[ 7881.088037][  T723] 1 lock held by oom02/112915:
[ 7881.088060][  T723]  #0: 000000003463bed2 (&mm->mmap_sem){....}, at:
vm_mmap_pgoff+0x8c/0x160
[ 7881.088095][  T723] 2 locks held by oom02/112916:
[ 7881.088134][  T723]  #0: 000000003463bed2 (&mm->mmap_sem){....}, at:
__mm_populate+0x12c/0x200
[ 7881.088180][  T723]  #1: 000000006dafe1e3 (fs_reclaim){....}, at:
fs_reclaim_acquire.part.17+0x10/0x60
[ 7881.088230][  T723] 1 lock held by oom02/112917:
[ 7881.088257][  T723]  #0: 000000003463bed2 (&mm->mmap_sem){....}, at:
do_mlock+0x88/0x2f0
[ 7881.088291][  T723] 1 lock held by oom02/112918:
[ 7881.088325][  T723]  #0: 000000003463bed2 (&mm->mmap_sem){....}, at:
vm_mmap_pgoff+0x8c/0x160
[ 7881.088370][  T723] 
[ 7881.088391][  T723] =============================================

> 
> From b31667210dd747f4d8aeb7bdc1f5c14f1f00bff5 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Wed, 31 Jul 2019 14:18:01 +0900
> Subject: [PATCH] mm: decrease NR_ISOALTED count at succesful migration
> 
> If migration fails, it should go back to LRU list so putback_lru_page
> could handle NR_ISOLATED count in pair with isolate_lru_page. However,
> if migration is successful, the page will be freed so no need to
> add the page back to LRU list. Thus, NR_ISOLATED count should be done
> in manually.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/migrate.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 84b89d2d69065..96ae0c3cada8d 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1166,6 +1166,7 @@ static ICE_noinline int unmap_and_move(new_page_t
> get_new_page,
>  {
>  	int rc = MIGRATEPAGE_SUCCESS;
>  	struct page *newpage;
> +	bool is_lru = __PageMovable(page);
>  
>  	if (!thp_migration_supported() && PageTransHuge(page))
>  		return -ENOMEM;
> @@ -1175,17 +1176,10 @@ static ICE_noinline int unmap_and_move(new_page_t
> get_new_page,
>  		return -ENOMEM;
>  
>  	if (page_count(page) == 1) {
> -		bool is_lru = !__PageMovable(page);
> -
>  		/* page was freed from under us. So we are done. */
>  		ClearPageActive(page);
>  		ClearPageUnevictable(page);
> -		if (likely(is_lru))
> -			mod_node_page_state(page_pgdat(page),
> -						NR_ISOLATED_ANON +
> -						page_is_file_cache(page),
> -						-hpage_nr_pages(page));
> -		else {
> +		if (unlikely(!is_lru)) {
>  			lock_page(page);
>  			if (!PageMovable(page))
>  				__ClearPageIsolated(page);
> @@ -1229,6 +1223,12 @@ static ICE_noinline int unmap_and_move(new_page_t
> get_new_page,
>  			if (set_hwpoison_free_buddy_page(page))
>  				num_poisoned_pages_inc();
>  		}
> +
> +		if (likely(is_lru))
> +			mod_node_page_state(page_pgdat(page),
> +					NR_ISOLATED_ANON +
> +						page_is_file_cache(page),
> +					-hpage_nr_pages(page));
>  	} else {
>  		if (rc != -EAGAIN) {
>  			if (likely(!__PageMovable(page))) {

