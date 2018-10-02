Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB426B000D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 07:03:48 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 71-v6so1461453plb.11
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 04:03:48 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w24-v6si11465960plp.110.2018.10.02.04.03.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 04:03:47 -0700 (PDT)
Date: Tue, 2 Oct 2018 14:03:38 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 4/6] tools/gup_benchmark: Allow user specified file
Message-ID: <20181002110338.fw7d4jv5e5a6yd4v@black.fi.intel.com>
References: <20180921223956.3485-1-keith.busch@intel.com>
 <20180921223956.3485-5-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921223956.3485-5-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, Sep 21, 2018 at 10:39:54PM +0000, Keith Busch wrote:
> The gup benchmark by default maps anonymous memory. This patch allows a
> user to specify a file to map, providing a means to test various
> file backings, like device and filesystem DAX.
> 
> Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  tools/testing/selftests/vm/gup_benchmark.c | 19 ++++++++++++++++---
>  1 file changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
> index b2082df8beb4..f2c99e2436f8 100644
> --- a/tools/testing/selftests/vm/gup_benchmark.c
> +++ b/tools/testing/selftests/vm/gup_benchmark.c
> @@ -33,9 +33,12 @@ int main(int argc, char **argv)
>  	unsigned long size = 128 * MB;
>  	int i, fd, opt, nr_pages = 1, thp = -1, repeats = 1, write = 0;
>  	int cmd = GUP_FAST_BENCHMARK;
> +	int file_map = -1;
> +	int flags = MAP_ANONYMOUS | MAP_PRIVATE;
> +	char *file = NULL;
>  	char *p;
>  
> -	while ((opt = getopt(argc, argv, "m:r:n:tTLU")) != -1) {
> +	while ((opt = getopt(argc, argv, "m:r:n:f:tTLU")) != -1) {
>  		switch (opt) {
>  		case 'm':
>  			size = atoi(optarg) * MB;
> @@ -61,11 +64,22 @@ int main(int argc, char **argv)
>  		case 'w':
>  			write = 1;
>  			break;
> +		case 'f':
> +			file = optarg;
> +			flags &= ~(MAP_PRIVATE | MAP_ANONYMOUS);
> +			flags |= MAP_SHARED;

Why do we want to assume shared mapping if a file is passed? Private-file
mapping is also valid target for the benchmark.

Maybe a separate option for shared? It would keep options more independent.

BTW, we can make a default file /dev/zero and don't have MAP_ANONYMOUS in
the flags: private mapping of /dev/zero would produce anonymous mapping.
No need in masking out MAP_ANONYMOUS on -f and no branch on 'if (file)'
below.

> +			break;
>  		default:
>  			return -1;
>  		}
>  	}
>  
> +	if (file) {
> +		file_map = open(file, O_RDWR|O_CREAT);
> +		if (file_map < 0)
> +			perror("open"), exit(file_map);
> +	}
> +
>  	gup.nr_pages_per_call = nr_pages;
>  	gup.flags = write;
>  
> @@ -73,8 +87,7 @@ int main(int argc, char **argv)
>  	if (fd == -1)
>  		perror("open"), exit(1);
>  
> -	p = mmap(NULL, size, PROT_READ | PROT_WRITE,
> -			MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
> +	p = mmap(NULL, size, PROT_READ | PROT_WRITE, flags, file_map, 0);
>  	if (p == MAP_FAILED)
>  		perror("mmap"), exit(1);
>  	gup.addr = (unsigned long)p;
> -- 
> 2.14.4
> 

-- 
 Kirill A. Shutemov
