Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A5E146B02C3
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 01:49:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z53so29311721wrz.10
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 22:49:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g20si1746657wrg.162.2017.07.25.22.49.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 22:49:40 -0700 (PDT)
Date: Wed, 26 Jul 2017 07:49:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2] selftests/vm: Add tests to validate mirror
 functionality with mremap
Message-ID: <20170726054938.GA2981@dhcp22.suse.cz>
References: <20170725063657.3915-1-khandual@linux.vnet.ibm.com>
 <20170725133604.GA27322@dhcp22.suse.cz>
 <32236948-422c-3519-7be3-88527895bf92@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <32236948-422c-3519-7be3-88527895bf92@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Wed 26-07-17 09:54:26, Anshuman Khandual wrote:
> On 07/25/2017 07:06 PM, Michal Hocko wrote:
> > On Tue 25-07-17 12:06:57, Anshuman Khandual wrote:
> > [...]
> >> diff --git a/tools/testing/selftests/vm/mremap_mirror_private_anon.c b/tools/testing/selftests/vm/mremap_mirror_private_anon.c
> > [...]
> >> +	ptr = mmap(NULL, alloc_size, PROT_READ | PROT_WRITE,
> >> +			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
> >> +	if (ptr == MAP_FAILED) {
> >> +		perror("map() failed");
> >> +		return -1;
> >> +	}
> >> +	memset(ptr, PATTERN, alloc_size);
> >> +
> >> +	mirror_ptr =  (char *) mremap(ptr, 0, alloc_size, MREMAP_MAYMOVE);
> >> +	if (mirror_ptr == MAP_FAILED) {
> >> +		perror("mremap() failed");
> >> +		return -1;
> >> +	}
> > 
> > What is the point of this test? It will break with Mike's patch very
> > soon. Btw. it never worked.
> 
> It works now. The new 'mirrored' buffer does not have same elements
> as that of the original one.

So what exactly are you testing here? The current implementation or the
semantic of mremap. Because having a different content after mremap
doesn't make _any_ sense to me. I might be misreading the intention of
the syscall but to me it sounds like the content should be same as the
original one... If my reading is wrong then -EINVAL for anon mremaps is
simply wrong.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
