Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DFEEC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 11:35:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07A822067D
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 11:35:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07A822067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97FB66B0005; Mon, 16 Sep 2019 07:35:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92F3B6B0006; Mon, 16 Sep 2019 07:35:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81E436B0007; Mon, 16 Sep 2019 07:35:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id 62D596B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:35:35 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 07EB063F0
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:35:35 +0000 (UTC)
X-FDA: 75940578630.22.error42_6ae4004e8800c
X-HE-Tag: error42_6ae4004e8800c
X-Filterd-Recvd-Size: 7193
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:35:34 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E888CAF11;
	Mon, 16 Sep 2019 11:35:32 +0000 (UTC)
Date: Mon, 16 Sep 2019 13:35:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Lucian Adrian Grijincu <lucian@fb.com>
Cc: linux-mm@kvack.org, Souptick Joarder <jrdr.linux@gmail.com>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Rik van Riel <riel@fb.com>, Roman Gushchin <guro@fb.com>,
	Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3] mm: memory: fix /proc/meminfo reporting for
 MLOCK_ONFAULT
Message-ID: <20190916113532.GE10231@dhcp22.suse.cz>
References: <20190913211119.416168-1-lucian@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190913211119.416168-1-lucian@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc Hugh]

On Fri 13-09-19 14:11:19, Lucian Adrian Grijincu wrote:
> As pages are faulted in MLOCK_ONFAULT correctly updates
> /proc/self/smaps, but doesn't update /proc/meminfo's Mlocked field.
> 
> - Before this /proc/meminfo fields didn't change as pages were faulted in:
> 
> = Start =
> /proc/meminfo
> Unevictable:       10128 kB
> Mlocked:           10132 kB
> = Creating testfile =
> 
> = after mlock2(MLOCK_ONFAULT) =
> /proc/meminfo
> Unevictable:       10128 kB
> Mlocked:           10132 kB
> /proc/self/smaps
> 7f8714000000-7f8754000000 rw-s 00000000 08:04 50857050   /root/testfile
> Locked:                0 kB
> 
> = after reading half of the file =
> /proc/meminfo
> Unevictable:       10128 kB
> Mlocked:           10132 kB
> /proc/self/smaps
> 7f8714000000-7f8754000000 rw-s 00000000 08:04 50857050   /root/testfile
> Locked:           524288 kB
> 
> = after reading the entire the file =
> /proc/meminfo
> Unevictable:       10128 kB
> Mlocked:           10132 kB
> /proc/self/smaps
> 7f8714000000-7f8754000000 rw-s 00000000 08:04 50857050   /root/testfile
> Locked:          1048576 kB
> 
> = after munmap =
> /proc/meminfo
> Unevictable:       10128 kB
> Mlocked:           10132 kB
> /proc/self/smaps
> 
> - After: /proc/meminfo fields are properly updated as pages are touched:
> 
> = Start =
> /proc/meminfo
> Unevictable:          60 kB
> Mlocked:              60 kB
> = Creating testfile =
> 
> = after mlock2(MLOCK_ONFAULT) =
> /proc/meminfo
> Unevictable:          60 kB
> Mlocked:              60 kB
> /proc/self/smaps
> 7f2b9c600000-7f2bdc600000 rw-s 00000000 08:04 63045798   /root/testfile
> Locked:                0 kB
> 
> = after reading half of the file =
> /proc/meminfo
> Unevictable:      524220 kB
> Mlocked:          524220 kB
> /proc/self/smaps
> 7f2b9c600000-7f2bdc600000 rw-s 00000000 08:04 63045798   /root/testfile
> Locked:           524288 kB
> 
> = after reading the entire the file =
> /proc/meminfo
> Unevictable:     1048496 kB
> Mlocked:         1048508 kB
> /proc/self/smaps
> 7f2b9c600000-7f2bdc600000 rw-s 00000000 08:04 63045798   /root/testfile
> Locked:          1048576 kB
> 
> = after munmap =
> /proc/meminfo
> Unevictable:         176 kB
> Mlocked:              60 kB
> /proc/self/smaps
> 
> Repro code.
> ---
> 
> int mlock2wrap(const void* addr, size_t len, int flags) {
>   return syscall(SYS_mlock2, addr, len, flags);
> }
> 
> void smaps() {
>   char smapscmd[1000];
>   snprintf(
>       smapscmd,
>       sizeof(smapscmd) - 1,
>       "grep testfile -A 20 /proc/%d/smaps | grep -E '(testfile|Locked)'",
>       getpid());
>   printf("/proc/self/smaps\n");
>   fflush(stdout);
>   system(smapscmd);
> }
> 
> void meminfo() {
>   const char* meminfocmd = "grep -E '(Mlocked|Unevictable)' /proc/meminfo";
>   printf("/proc/meminfo\n");
>   fflush(stdout);
>   system(meminfocmd);
> }
> 
>   {                                                 \
>     int rc = (call);                                \
>     if (rc != 0) {                                  \
>       printf("error %d %s\n", rc, strerror(errno)); \
>       exit(1);                                      \
>     }                                               \
>   }
> int main(int argc, char* argv[]) {
>   printf("= Start =\n");
>   meminfo();
> 
>   printf("= Creating testfile =\n");
>   size_t size = 1 << 30; // 1 GiB
>   int fd = open("testfile", O_CREAT | O_RDWR, 0666);
>   {
>     void* buf = malloc(size);
>     write(fd, buf, size);
>     free(buf);
>   }
>   int ret = 0;
>   void* addr = NULL;
>   addr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
> 
>   if (argc > 1) {
>     PCHECK(mlock2wrap(addr, size, MLOCK_ONFAULT));
>     printf("= after mlock2(MLOCK_ONFAULT) =\n");
>     meminfo();
>     smaps();
> 
>     for (size_t i = 0; i < size / 2; i += 4096) {
>       ret += ((char*)addr)[i];
>     }
>     printf("= after reading half of the file =\n");
>     meminfo();
>     smaps();
> 
>     for (size_t i = 0; i < size; i += 4096) {
>       ret += ((char*)addr)[i];
>     }
>     printf("= after reading the entire the file =\n");
>     meminfo();
>     smaps();
> 
>   } else {
>     PCHECK(mlock(addr, size));
>     printf("= after mlock =\n");
>     meminfo();
>     smaps();
>   }
> 
>   PCHECK(munmap(addr, size));
>   printf("= after munmap =\n");
>   meminfo();
>   smaps();
> 
>   return ret;
> }
> 
> ---
> 
> Signed-off-by: Lucian Adrian Grijincu <lucian@fb.com>
> Acked-by: Souptick Joarder <jrdr.linux@gmail.com>

Fixes: b0f205c2a308 ("mm: mlock: add mlock flags to enable VM_LOCKONFAULT usage")

I am not really sure a backport to stable is really needed because an
imprecise accounting is not really critical. Pages should eventually
get accounted under memory pressure when they are attempted to unmap
IIRC.

Btw. the changelog could benefit from a more details on the issue and
the fix description. The reproducer is really nice but it doesn't really
explain the maze of the mlock accounting and why only the file backed
memory has a problem.

> ---
>  mm/memory.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e0c232fe81d9..55da24f33bc4 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3311,6 +3311,8 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
>  	} else {
>  		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
>  		page_add_file_rmap(page, false);
> +		if (vma->vm_flags & VM_LOCKED && !PageTransCompound(page))
> +			mlock_vma_page(page);
>  	}
>  	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, entry);

I dunno. Handling it here in alloc_set_pte sounds a bit weird to me.
Altough we already do mlock for CoW pages there, I thought this was more
of an exception.
Is there any real reason why this cannot be done in the standard #PF
path? finish_fault for example?
-- 
Michal Hocko
SUSE Labs

