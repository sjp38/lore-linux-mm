Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2E36A6B006C
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 19:52:21 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so77779560pad.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 16:52:20 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id rx9si368629pbc.109.2015.03.26.16.52.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 16:52:19 -0700 (PDT)
Message-ID: <1427413936.23142.4.camel@ellerman.id.au>
Subject: Re: [patch 2/2] mm, selftests: test return value of munmap for
 MAP_HUGETLB memory
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Fri, 27 Mar 2015 10:52:16 +1100
In-Reply-To: <alpine.DEB.2.10.1503261623280.20009@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com>
	 <alpine.DEB.2.10.1503261623280.20009@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Davide Libenzi <davidel@xmailserver.org>, Luiz Capitulino <lcapitulino@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-doc@vger.kernel.org

On Thu, 2015-03-26 at 16:23 -0700, David Rientjes wrote:
> When MAP_HUGETLB memory is unmapped, the length must be hugepage aligned,
> otherwise it fails with -EINVAL.
> 
> All tests currently behave correctly, but it's better to explcitly test
> the return value for completeness and document the requirement,
> especially if users copy map_hugetlb.c as a sample implementation.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  tools/testing/selftests/powerpc/mm/hugetlb_vs_thp_test.c | 8 ++++++--
> 
> diff --git a/tools/testing/selftests/powerpc/mm/hugetlb_vs_thp_test.c b/tools/testing/selftests/powerpc/mm/hugetlb_vs_thp_test.c
> --- a/tools/testing/selftests/powerpc/mm/hugetlb_vs_thp_test.c
> +++ b/tools/testing/selftests/powerpc/mm/hugetlb_vs_thp_test.c
> @@ -21,9 +21,13 @@ static int test_body(void)
>  		 * Typically the mmap will fail because no huge pages are
>  		 * allocated on the system. But if there are huge pages
>  		 * allocated the mmap will succeed. That's fine too, we just
> -		 * munmap here before continuing.
> +		 * munmap here before continuing.  munmap() length of
> +		 * MAP_HUGETLB memory must be hugepage aligned.
>  		 */
> -		munmap(addr, SIZE);
> +		if (munmap(addr, SIZE)) {
> +			perror("munmap");
> +			return 1;
> +		}
>  	}
>  
>  	p = mmap(addr, SIZE, PROT_READ | PROT_WRITE,

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
