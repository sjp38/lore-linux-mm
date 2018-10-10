Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B30556B0006
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 18:31:04 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b22-v6so6116247pfc.18
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 15:31:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e7-v6si25472643pls.366.2018.10.10.15.31.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 15:31:03 -0700 (PDT)
Date: Wed, 10 Oct 2018 15:31:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/6] tools/gup_benchmark: Allow user specified file
Message-Id: <20181010153101.4f5dcf6dcc01e71934eeb1ba@linux-foundation.org>
In-Reply-To: <20181010195605.10689-4-keith.busch@intel.com>
References: <20181010195605.10689-1-keith.busch@intel.com>
	<20181010195605.10689-4-keith.busch@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, 10 Oct 2018 13:56:03 -0600 Keith Busch <keith.busch@intel.com> wrote:

> This patch allows a user to specify a file to map by adding a new option,
> '-f', providing a means to test various file backings.
> 
> If not specified, the benchmark will use a private mapping of /dev/zero,
> which produces an anonymous mapping as before.
> 
> ...
>
> --- a/tools/testing/selftests/vm/gup_benchmark.c
> +++ b/tools/testing/selftests/vm/gup_benchmark.c
>
> ...
>
> @@ -61,11 +62,18 @@ int main(int argc, char **argv)
>  		case 'w':
>  			write = 1;
>  			break;
> +		case 'f':
> +			file = optarg;
> +			break;
>  		default:
>  			return -1;
>  		}
>  	}
>  
> +	filed = open(file, O_RDWR|O_CREAT);
> +	if (filed < 0)
> +		perror("open"), exit(filed);

Ick.  Like this, please:

--- a/tools/testing/selftests/vm/gup_benchmark.c~tools-gup_benchmark-allow-user-specified-file-fix
+++ a/tools/testing/selftests/vm/gup_benchmark.c
@@ -71,8 +71,10 @@ int main(int argc, char **argv)
 	}
 
 	filed = open(file, O_RDWR|O_CREAT);
-	if (filed < 0)
-		perror("open"), exit(filed);
+	if (filed < 0) {
+		perror("open");
+		exit(filed);
+	}
 
 	gup.nr_pages_per_call = nr_pages;
 	gup.flags = write;
