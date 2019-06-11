Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0F3AC06508
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 16:46:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E23F2086A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 16:46:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E23F2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97BD56B000C; Tue, 11 Jun 2019 12:46:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9526C6B000D; Tue, 11 Jun 2019 12:46:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 841146B0010; Tue, 11 Jun 2019 12:46:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 476DF6B000C
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:46:19 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x18so9993818pfj.4
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 09:46:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0FUoinYz8ICVlKkA2xZIuylvxoLe/PvTixinpjR6RXQ=;
        b=do+Vtu8sWyfG/1ZbOHzE/DNyHYTjNNqdG+jRiyKh0Ni0J66txfNsGIEx1zMNObS+yF
         f+s5ZCYb2HAVYjJchV/TlmohOGmXy9rvaDsbxi6wrNW5glBhHlVXIFa671urHsaze+u7
         lrPNB/oH4DDr2Mas7qWPeo+vYYythJ1U6fjhbiq6SDaAyzc2Eo3Exy9/D11mRwmkWYCv
         EWvWGXeaA1ZQ0zhqlPi7/nfp+qWFtjJ4WKBe6pAFXV80lQNABaS19hkcqPeZAUyiYsPc
         8vNYnBrImbxu7VYzi/FLPshoS53mrtdxUn5DrBGE2ayNGnZvufcbQRReDM+nA9+T3RNU
         Nu+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWctmG1N3EQf4uJkIfzyxLf4/nBNfEJYW7L2+Mfvlhm0I5JD07R
	05uugn+kWz26a7r9Ef8VQC6tD7qRQT3af+Ni8uCz8rNdk/CxiK6pYbkOXMMkS+HxQiOK6yVZlKj
	/8mnPLjVSdTRPBtQd5gIKvQXl/RhiN2ZTaIEgGJeQ7bY8LZg8dkTXkS3YZP0RDvgjTA==
X-Received: by 2002:a17:90a:9385:: with SMTP id q5mr27276838pjo.126.1560271578906;
        Tue, 11 Jun 2019 09:46:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyLHbOf8sD94VhFQlS6BQFWRCGK2YovylBeUVHmIVRmXEDcHIAEvcmPnUTewhGjzm5zSdC
X-Received: by 2002:a17:90a:9385:: with SMTP id q5mr27276788pjo.126.1560271577946;
        Tue, 11 Jun 2019 09:46:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560271577; cv=none;
        d=google.com; s=arc-20160816;
        b=nEv773K95OsP1YGh+iSYaGrz4Rd7yw1rB00nYffpxF/E+qj5iQwydZhDl0iErzih+c
         SlRc14/sqgS5CubWym5jJBTb0/fddrE/+TS7FCAcNrtYsJ6OJIzSYCFz3VhiNJQQV5O3
         kJ9WyiZCqVBdGjqzHEVPCkEoSj1kR2cTuUXcX6uyHNbhUAhjneE9sP5pQ8FLoJL4/f3N
         +RhnNZGS4saDXFI6dAzUspfjvf4bthAubwu1ieggZQhZ5HIB32Z8sr6RWGUBqJ6hnE8u
         Mypa9wkAG4wSjAgeBNx21oD94UuGckOQKCqGbKuOHQcaDxiBEcTkuz2mHayJDU2uFf8c
         /gDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0FUoinYz8ICVlKkA2xZIuylvxoLe/PvTixinpjR6RXQ=;
        b=YooXtVuJ/RVZnqOZIU0nQGS2r094EmWqrL9aoWKugKBGvdpDMiiZp5XF2cpgCQkAIl
         N5iEpcUUFX82c3kjPFJkQkELkJp6NW3Ufvoem4tJrRWgBljnfEk03UBYw4oAxNDCro5Z
         cIIguhHA7gJlDoB638yAdfonUgQVrEXvYemiZUigjaNId9KHnALnhv/IigX4oMdxVIUQ
         h0S8r3kFbt0f/69G14qSfh4zfoFVHSlRIGd+C5nI2j5vL1QpbIWoTafHqqkQSVtCDFZ6
         lIL6qittwHQEbnTZha8eQ/bucP9eFwpD+HySd8fwP6N2vMTnOoJcbm1c8vfuj+c4oMOQ
         yfrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o4si13945043pfb.274.2019.06.11.09.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 09:46:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Jun 2019 09:46:16 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 11 Jun 2019 09:46:16 -0700
Date: Tue, 11 Jun 2019 09:47:34 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-ID: <20190611164733.GA14336@iweiny-DESK2.sc.intel.com>
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
 <20190605144912.f0059d4bd13c563ddb37877e@linux-foundation.org>
 <CAFgQCTur5ReVHm6NHdbD3wWM5WOiAzhfEXdLnBGRdZtf7q1HFw@mail.gmail.com>
 <2b0a65ec-4fb0-430e-3e6a-b713fb5bb28f@nvidia.com>
 <CAFgQCTtS7qOByXBnGzCW-Rm9fiNsVmhQTgqmNU920m77XyAwZQ@mail.gmail.com>
 <20190611122935.GA9919@dhcp-128-55.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611122935.GA9919@dhcp-128-55.nay.redhat.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 08:29:35PM +0800, Pingfan Liu wrote:
> On Fri, Jun 07, 2019 at 02:10:15PM +0800, Pingfan Liu wrote:
> > On Fri, Jun 7, 2019 at 5:17 AM John Hubbard <jhubbard@nvidia.com> wrote:
> > >
> > > On 6/5/19 7:19 PM, Pingfan Liu wrote:
> > > > On Thu, Jun 6, 2019 at 5:49 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> > > ...
> > > >>> --- a/mm/gup.c
> > > >>> +++ b/mm/gup.c
> > > >>> @@ -2196,6 +2196,26 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
> > > >>>       return ret;
> > > >>>  }
> > > >>>
> > > >>> +#ifdef CONFIG_CMA
> > > >>> +static inline int reject_cma_pages(int nr_pinned, struct page **pages)
> > > >>> +{
> > > >>> +     int i;
> > > >>> +
> > > >>> +     for (i = 0; i < nr_pinned; i++)
> > > >>> +             if (is_migrate_cma_page(pages[i])) {
> > > >>> +                     put_user_pages(pages + i, nr_pinned - i);
> > > >>> +                     return i;
> > > >>> +             }
> > > >>> +
> > > >>> +     return nr_pinned;
> > > >>> +}
> > > >>
> > > >> There's no point in inlining this.
> > > > OK, will drop it in V4.
> > > >
> > > >>
> > > >> The code seems inefficient.  If it encounters a single CMA page it can
> > > >> end up discarding a possibly significant number of non-CMA pages.  I
> > > > The trick is the page is not be discarded, in fact, they are still be
> > > > referrenced by pte. We just leave the slow path to pick up the non-CMA
> > > > pages again.
> > > >
> > > >> guess that doesn't matter much, as get_user_pages(FOLL_LONGTERM) is
> > > >> rare.  But could we avoid this (and the second pass across pages[]) by
> > > >> checking for a CMA page within gup_pte_range()?
> > > > It will spread the same logic to hugetlb pte and normal pte. And no
> > > > improvement in performance due to slow path. So I think maybe it is
> > > > not worth.
> > > >
> > > >>
> > >
> > > I think the concern is: for the successful gup_fast case with no CMA
> > > pages, this patch is adding another complete loop through all the
> > > pages. In the fast case.
> > >
> > > If the check were instead done as part of the gup_pte_range(), then
> > > it would be a little more efficient for that case.
> > >
> > > As for whether it's worth it, *probably* this is too small an effect to measure.
> > > But in order to attempt a measurement: running fio (https://github.com/axboe/fio)
> > > with O_DIRECT on an NVMe drive, might shed some light. Here's an fio.conf file
> > > that Jan Kara and Tom Talpey helped me come up with, for related testing:
> > >
> > > [reader]
> > > direct=1
> > > ioengine=libaio
> > > blocksize=4096
> > > size=1g
> > > numjobs=1
> > > rw=read
> > > iodepth=64
> > >
> Unable to get a NVME device to have a test. And when testing fio on the
> tranditional disk, I got the error "fio: engine libaio not loadable
> fio: failed to load engine
> fio: file:ioengines.c:89, func=dlopen, error=libaio: cannot open shared object file: No such file or directory"
> 
> But I found a test case which can be slightly adjusted to met the aim.
> It is tools/testing/selftests/vm/gup_benchmark.c
> 
> Test enviroment:
>   MemTotal:       264079324 kB
>   MemFree:        262306788 kB
>   CmaTotal:              0 kB
>   CmaFree:               0 kB
>   on AMD EPYC 7601
> 
> Test command:
>   gup_benchmark -r 100 -n 64
>   gup_benchmark -r 100 -n 64 -l
> where -r stands for repeat times, -n is nr_pages param for
> get_user_pages_fast(), -l is a new option to test FOLL_LONGTERM in fast
> path, see a patch at the tail.

Thanks!  That is a good test to add.  You should add the patch to the series.

> 
> Test result:
> w/o     477.800000
> w/o-l   481.070000
> a       481.800000
> a-l     640.410000
> b       466.240000  (question a: b outperforms w/o ?)
> b-l     529.740000
> 
> Where w/o is baseline without any patch using v5.2-rc2, a is this series, b
> does the check in gup_pte_range(). '-l' means FOLL_LONGTERM.
> 
> I am suprised that b-l has about 17% improvement than a. (640.41 -529.74)/640.41

Wow that is bigger than I would have thought.  I suspect it gets worse as -n
increases?

>
> As for "question a: b outperforms w/o ?", I can not figure out why, maybe it can be
> considered as variance.

:-/

Does this change with larger -r or -n values?

> 
> Based on the above result, I think it is better to do the check inside
> gup_pte_range().
> 
> Any comment?

I agree.

Ira

> 
> Thanks,
> 
> 
> > Yeah, agreed. Data is more persuasive. Thanks for your suggestion. I
> > will try to bring out the result.
> > 
> > Thanks,
> >   Pingfan
> > 
> 

> ---
> Patch to do check inside gup_pte_range()
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 2ce3091..ba213a0 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1757,6 +1757,10 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
>  		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
>  		page = pte_page(pte);
>  
> +		if (unlikely(flags & FOLL_LONGTERM) &&
> +			is_migrate_cma_page(page))
> +				goto pte_unmap;
> +
>  		head = try_get_compound_head(page, 1);
>  		if (!head)
>  			goto pte_unmap;
> @@ -1900,6 +1904,12 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
>  		refs++;
>  	} while (addr += PAGE_SIZE, addr != end);
>  
> +	if (unlikely(flags & FOLL_LONGTERM) &&
> +		is_migrate_cma_page(page)) {
> +		*nr -= refs;
> +		return 0;
> +	}
> +
>  	head = try_get_compound_head(pmd_page(orig), refs);
>  	if (!head) {
>  		*nr -= refs;
> @@ -1941,6 +1951,12 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
>  		refs++;
>  	} while (addr += PAGE_SIZE, addr != end);
>  
> +	if (unlikely(flags & FOLL_LONGTERM) &&
> +		is_migrate_cma_page(page)) {
> +		*nr -= refs;
> +		return 0;
> +	}
> +
>  	head = try_get_compound_head(pud_page(orig), refs);
>  	if (!head) {
>  		*nr -= refs;
> @@ -1978,6 +1994,12 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
>  		refs++;
>  	} while (addr += PAGE_SIZE, addr != end);
>  
> +	if (unlikely(flags & FOLL_LONGTERM) &&
> +		is_migrate_cma_page(page)) {
> +		*nr -= refs;
> +		return 0;
> +	}
> +
>  	head = try_get_compound_head(pgd_page(orig), refs);
>  	if (!head) {
>  		*nr -= refs;

> ---
> Patch for testing
> 
> diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
> index 7dd602d..61dec5f 100644
> --- a/mm/gup_benchmark.c
> +++ b/mm/gup_benchmark.c
> @@ -6,8 +6,9 @@
>  #include <linux/debugfs.h>
>  
>  #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
> -#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
> -#define GUP_BENCHMARK		_IOWR('g', 3, struct gup_benchmark)
> +#define GUP_FAST_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
> +#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 3, struct gup_benchmark)
> +#define GUP_BENCHMARK		_IOWR('g', 4, struct gup_benchmark)
>  
>  struct gup_benchmark {
>  	__u64 get_delta_usec;
> @@ -53,6 +54,11 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
>  			nr = get_user_pages_fast(addr, nr, gup->flags & 1,
>  						 pages + i);
>  			break;
> +		case GUP_FAST_LONGTERM_BENCHMARK:
> +			nr = get_user_pages_fast(addr, nr,
> +						 (gup->flags & 1) | FOLL_LONGTERM,
> +						 pages + i);
> +			break;
>  		case GUP_LONGTERM_BENCHMARK:
>  			nr = get_user_pages(addr, nr,
>  					    (gup->flags & 1) | FOLL_LONGTERM,
> @@ -96,6 +102,7 @@ static long gup_benchmark_ioctl(struct file *filep, unsigned int cmd,
>  
>  	switch (cmd) {
>  	case GUP_FAST_BENCHMARK:
> +	case GUP_FAST_LONGTERM_BENCHMARK:
>  	case GUP_LONGTERM_BENCHMARK:
>  	case GUP_BENCHMARK:
>  		break;
> diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
> index c0534e2..ade8acb 100644
> --- a/tools/testing/selftests/vm/gup_benchmark.c
> +++ b/tools/testing/selftests/vm/gup_benchmark.c
> @@ -15,8 +15,9 @@
>  #define PAGE_SIZE sysconf(_SC_PAGESIZE)
>  
>  #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
> -#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
> -#define GUP_BENCHMARK		_IOWR('g', 3, struct gup_benchmark)
> +#define GUP_FAST_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
> +#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 3, struct gup_benchmark)
> +#define GUP_BENCHMARK		_IOWR('g', 4, struct gup_benchmark)
>  
>  struct gup_benchmark {
>  	__u64 get_delta_usec;
> @@ -37,7 +38,7 @@ int main(int argc, char **argv)
>  	char *file = "/dev/zero";
>  	char *p;
>  
> -	while ((opt = getopt(argc, argv, "m:r:n:f:tTLUSH")) != -1) {
> +	while ((opt = getopt(argc, argv, "m:r:n:f:tTlLUSH")) != -1) {
>  		switch (opt) {
>  		case 'm':
>  			size = atoi(optarg) * MB;
> @@ -54,6 +55,9 @@ int main(int argc, char **argv)
>  		case 'T':
>  			thp = 0;
>  			break;
> +		case 'l':
> +			cmd = GUP_FAST_LONGTERM_BENCHMARK;
> +			break;
>  		case 'L':
>  			cmd = GUP_LONGTERM_BENCHMARK;
>  			break;
> -- 
> 2.7.5
> 

