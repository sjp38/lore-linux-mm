Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBE63C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 17:24:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6996020896
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 17:24:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6996020896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4AC66B0003; Mon, 25 Mar 2019 13:24:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD39F6B0006; Mon, 25 Mar 2019 13:24:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4CAF6B0007; Mon, 25 Mar 2019 13:24:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75D396B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 13:24:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i14so5874826pfd.10
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:24:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FyVDYYlU946lZs9EBxD62gk1T5Fw/JvSPMXxxflFzfA=;
        b=KsOd+eHLY0pdRNDB+8Y+/91ZxAAwkufo0yUZFlkTm6erHL36+el25WRJdUKDZUs3jQ
         l/8y316ox0++UVk92BjfzQL/lFIimFSsayHfP58YIcNtmxIrozD1pVKreNWgHfZYMh4F
         BmbsF1sUx0w6geLc+6y8Q93ZUQ5hBzntPdNDztCybPIE8gl1xG02hNpDZ/90exRoKr7Q
         67KvClNWmheI3kQnxuu4K1ptYAayiInCpgLhbgQzI8x3j2icffoPoHg5KSv1FQMgjdXW
         AaRLHBMwfDJs7pIgkMfPZzsU3+E9/s42KzvPc5xF5vuLYsPHSybgw1rJOiMhAWkyCaSY
         q/Cw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUBHhnyOy7Q/A1CAsse6AIvbw9GLUrBqbNsazGblGC1ugcxvRJ8
	jr0mnNAW8u7fKfZwfsk1zDZHh3wlDzDhgnQ2tKl4K5cQVJmukUgwu4xNAltjc1cag3QuJCD/nNP
	auZUb56amnhNAwK7wrzWzXxhFTupH7baTZybfCiD5arcYEZ2M7/mZJ7BJlqWxycy8IQ==
X-Received: by 2002:a63:4620:: with SMTP id t32mr22599336pga.363.1553534671041;
        Mon, 25 Mar 2019 10:24:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZySm3FXR5obWTDrBiRoq5g8zX9PzxQFk2H8jgjXuRcLIe5iR2SvTVhGJUKVnpk58xrSzv
X-Received: by 2002:a63:4620:: with SMTP id t32mr22599192pga.363.1553534668686;
        Mon, 25 Mar 2019 10:24:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553534668; cv=none;
        d=google.com; s=arc-20160816;
        b=mb2m8a29BCiERduL/OlQfiFrDe69aHdQSbSFD+DSv3kAPCbE2hpScbky9sjnqS8EbX
         mwDIMiSOO5qiD9+4R3RoAncfCtN9xIuuCO1m+6iOXiMyaPPhOa8GRHB04MHrpswM9dLq
         Xh+6Vvoy9JIQXzr20YedD1QnZIiXrZbNzgLNJQtYM59zWHIl8gQAM77yYsy4tjsHFvrv
         C6pMHeU+eKwDW7xZUR0lyKy2yqWBXlUURsq1X3Cui5+9wl+52euuVRkVvvqqIDoXHykZ
         9zxbQuRZHMIQqLtl32sJDZupOkaGnNhy+ew8ggteHdAgvWBpsF7RezZH6tr3na7yZ/+l
         9P1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FyVDYYlU946lZs9EBxD62gk1T5Fw/JvSPMXxxflFzfA=;
        b=RkTlGrxSgIEJLxYICULbGQBpWt/w8hV0KuGbxYjIU3vd1eq+2qBnnF7atmecaWoJOQ
         EUdVbj/E1LJsDxbtWWUxbmCuTRX3eShjrlHBB+ywskk9CQGJ8HKNVm0VKHR639qu7tAb
         1lgioMVFMQ7+/7GzhfKxNBgshX+z1Y+02O3nK1hq+nPpYGifTRaRKbjeXRfNZky57WkL
         5ss/JXkTkhnt4Xu4SsCS3ud4sHjrjDvF5geylYr4erwAqArKYLsLIH+rpnCOurKdUzJM
         bTQVIbYrqYpaBPyME0W4m1Ovi5gd5cPu0WmCgOToxHHupm82RLxLwfiT5l7GzKOG/Fkj
         v17w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id a22si8286654pfc.217.2019.03.25.10.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 10:24:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Mar 2019 10:24:27 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,269,1549958400"; 
   d="scan'208";a="125738993"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga007.jf.intel.com with ESMTP; 25 Mar 2019 10:24:26 -0700
Date: Mon, 25 Mar 2019 02:23:15 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-mips@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	linux-s390 <linux-s390@vger.kernel.org>,
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: [RESEND 4/7] mm/gup: Add FOLL_LONGTERM capability to GUP fast
Message-ID: <20190325092314.GF16366@iweiny-DESK2.sc.intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
 <20190317183438.2057-5-ira.weiny@intel.com>
 <CAA9_cmcx-Bqo=CFuSj7Xcap3e5uaAot2reL2T74C47Ut6_KtQw@mail.gmail.com>
 <20190325084225.GC16366@iweiny-DESK2.sc.intel.com>
 <20190325164713.GC9949@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190325164713.GC9949@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 01:47:13PM -0300, Jason Gunthorpe wrote:
> On Mon, Mar 25, 2019 at 01:42:26AM -0700, Ira Weiny wrote:
> > On Fri, Mar 22, 2019 at 03:12:55PM -0700, Dan Williams wrote:
> > > On Sun, Mar 17, 2019 at 7:36 PM <ira.weiny@intel.com> wrote:
> > > >
> > > > From: Ira Weiny <ira.weiny@intel.com>
> > > >
> > > > DAX pages were previously unprotected from longterm pins when users
> > > > called get_user_pages_fast().
> > > >
> > > > Use the new FOLL_LONGTERM flag to check for DEVMAP pages and fall
> > > > back to regular GUP processing if a DEVMAP page is encountered.
> > > >
> > > > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > > >  mm/gup.c | 29 +++++++++++++++++++++++++----
> > > >  1 file changed, 25 insertions(+), 4 deletions(-)
> > > >
> > > > diff --git a/mm/gup.c b/mm/gup.c
> > > > index 0684a9536207..173db0c44678 100644
> > > > +++ b/mm/gup.c
> > > > @@ -1600,6 +1600,9 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
> > > >                         goto pte_unmap;
> > > >
> > > >                 if (pte_devmap(pte)) {
> > > > +                       if (unlikely(flags & FOLL_LONGTERM))
> > > > +                               goto pte_unmap;
> > > > +
> > > >                         pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
> > > >                         if (unlikely(!pgmap)) {
> > > >                                 undo_dev_pagemap(nr, nr_start, pages);
> > > > @@ -1739,8 +1742,11 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
> > > >         if (!pmd_access_permitted(orig, flags & FOLL_WRITE))
> > > >                 return 0;
> > > >
> > > > -       if (pmd_devmap(orig))
> > > > +       if (pmd_devmap(orig)) {
> > > > +               if (unlikely(flags & FOLL_LONGTERM))
> > > > +                       return 0;
> > > >                 return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr);
> > > > +       }
> > > >
> > > >         refs = 0;
> > > >         page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> > > > @@ -1777,8 +1783,11 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
> > > >         if (!pud_access_permitted(orig, flags & FOLL_WRITE))
> > > >                 return 0;
> > > >
> > > > -       if (pud_devmap(orig))
> > > > +       if (pud_devmap(orig)) {
> > > > +               if (unlikely(flags & FOLL_LONGTERM))
> > > > +                       return 0;
> > > >                 return __gup_device_huge_pud(orig, pudp, addr, end, pages, nr);
> > > > +       }
> > > >
> > > >         refs = 0;
> > > >         page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> > > > @@ -2066,8 +2075,20 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
> > > >                 start += nr << PAGE_SHIFT;
> > > >                 pages += nr;
> > > >
> > > > -               ret = get_user_pages_unlocked(start, nr_pages - nr, pages,
> > > > -                                             gup_flags);
> > > > +               if (gup_flags & FOLL_LONGTERM) {
> > > > +                       down_read(&current->mm->mmap_sem);
> > > > +                       ret = __gup_longterm_locked(current, current->mm,
> > > > +                                                   start, nr_pages - nr,
> > > > +                                                   pages, NULL, gup_flags);
> > > > +                       up_read(&current->mm->mmap_sem);
> > > > +               } else {
> > > > +                       /*
> > > > +                        * retain FAULT_FOLL_ALLOW_RETRY optimization if
> > > > +                        * possible
> > > > +                        */
> > > > +                       ret = get_user_pages_unlocked(start, nr_pages - nr,
> > > > +                                                     pages, gup_flags);
> > > 
> > > I couldn't immediately grok why this path needs to branch on
> > > FOLL_LONGTERM? Won't get_user_pages_unlocked(..., FOLL_LONGTERM) do
> > > the right thing?
> > 
> > Unfortunately holding the lock is required to support FOLL_LONGTERM (to check
> > the VMAs) but we don't want to hold the lock to be optimal (specifically allow
> > FAULT_FOLL_ALLOW_RETRY).  So I'm maintaining the optimization for *_fast users
> > who do not specify FOLL_LONGTERM.
> > 
> > Another way to do this would have been to define __gup_longterm_unlocked with
> > the above logic, but that seemed overkill at this point.
> 
> get_user_pages_unlocked() is an exported symbol, shouldn't it work
> with the FOLL_LONGTERM flag?
> 
> I think it should even though we have no user..
> 
> Otherwise the GUP API just gets more confusing.

I agree WRT to the API.  But I think callers of get_user_pages_unlocked() are
not going to get the behavior they want if they specify FOLL_LONGTERM.

What I could do is BUG_ON (or just WARN_ON) if unlocked is called with
FOLL_LONGTERM similar to the code in get_user_pages_locked() which does not
allow locked and vmas to be passed together:

        if (locked) {
                /* if VM_FAULT_RETRY can be returned, vmas become invalid */
                BUG_ON(vmas);
                /* check caller initialized locked */
                BUG_ON(*locked != 1);
        }

Combining Dan's comment and yours; I could do something like below? (not even
compile tested)  Coded with WARN_ON because technically I _think_ the
FOLL_LONGTERM would "work" but not be optimal.  I'm just not 100% sure.  A
BUG_ON would be most protective IMO.


diff --git a/mm/gup.c b/mm/gup.c
index 173db0c44678..8e31411f485f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1014,6 +1014,29 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
+long __gup_longterm_unlocked(unsigned long start, unsigned long nr_pages,
+			     struct page **pages, unsigned int gup_flags)
+{
+	struct mm_struct *mm = current->mm;
+	int locked = 1;
+	long ret;
+
+	down_read(&mm->mmap_sem);
+	if (gup_flags & FOLL_LONGTERM) {
+		ret = __gup_longterm_locked(current, mm,
+					    start, nr_pages - nr,
+					    pages, NULL, gup_flags);
+	} else {
+		ret = __get_user_pages_locked(current, mm, start, nr_pages,
+					      pages, NULL, &locked,
+					      gup_flags | FOLL_TOUCH);
+	}
+	if (locked)
+		up_read(&mm->mmap_sem);
+
+	return ret;
+}
+
 /*
  * get_user_pages_unlocked() is suitable to replace the form:
  *
@@ -1032,16 +1055,9 @@ EXPORT_SYMBOL(get_user_pages_locked);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 			     struct page **pages, unsigned int gup_flags)
 {
-	struct mm_struct *mm = current->mm;
-	int locked = 1;
-	long ret;
+	WARN_ON(gup_flags & FOLL_LONGTERM);
 
-	down_read(&mm->mmap_sem);
-	ret = __get_user_pages_locked(current, mm, start, nr_pages, pages, NULL,
-				      &locked, gup_flags | FOLL_TOUCH);
-	if (locked)
-		up_read(&mm->mmap_sem);
-	return ret;
+	__gup_longterm_unlocked(start, nr_pages, pages, gup_flags);
 }
 EXPORT_SYMBOL(get_user_pages_unlocked);
 
@@ -2075,20 +2091,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		if (gup_flags & FOLL_LONGTERM) {
-			down_read(&current->mm->mmap_sem);
-			ret = __gup_longterm_locked(current, current->mm,
-						    start, nr_pages - nr,
-						    pages, NULL, gup_flags);
-			up_read(&current->mm->mmap_sem);
-		} else {
-			/*
-			 * retain FAULT_FOLL_ALLOW_RETRY optimization if
-			 * possible
-			 */
-			ret = get_user_pages_unlocked(start, nr_pages - nr,
-						      pages, gup_flags);
-		}
+		__gup_longterm_unlocked();
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {

