Date: Mon, 9 Jun 2008 03:41:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 15/21] hugetlb: override default huge page size
Message-Id: <20080609034126.cf4e8df4.akpm@linux-foundation.org>
In-Reply-To: <20080604113112.902971712@amd.local0.net>
References: <20080604112939.789444496@amd.local0.net>
	<20080604113112.902971712@amd.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 04 Jun 2008 21:29:54 +1000 npiggin@suse.de wrote:

> Allow configurations with the default huge page size which is different to
> the traditional HPAGE_SIZE size. The default huge page size is the one
> represented in the legacy /proc ABIs, SHM, and which is defaulted to when
> mounting hugetlbfs filesystems.
> 
> This is implemented with a new kernel option default_hugepagesz=, which
> defaults to HPAGE_SIZE if not specified.
> 
> ...
>
> --- linux-2.6.orig/mm/hugetlb.c	2008-06-04 20:51:23.000000000 +1000
> +++ linux-2.6/mm/hugetlb.c	2008-06-04 20:51:24.000000000 +1000
> @@ -34,6 +34,7 @@ struct hstate hstates[HUGE_MAX_HSTATE];
>  /* for command line parsing */
>  static struct hstate * __initdata parsed_hstate = NULL;
>  static unsigned long __initdata default_hstate_max_huge_pages = 0;
> +static unsigned long __initdata default_hstate_size = HPAGE_SIZE;

ia64:

mm/hugetlb.c:39: error: initializer element is not constant

(wtf?)


Hopefully this'll fix it.

--- a/mm/hugetlb.c~hugetlb-override-default-huge-page-size-ia64-build
+++ a/mm/hugetlb.c
@@ -34,7 +34,7 @@ struct hstate hstates[HUGE_MAX_HSTATE];
 /* for command line parsing */
 static struct hstate * __initdata parsed_hstate;
 static unsigned long __initdata default_hstate_max_huge_pages;
-static unsigned long __initdata default_hstate_size = HPAGE_SIZE;
+static unsigned long __initdata default_hstate_size;
 
 #define for_each_hstate(h) \
 	for ((h) = hstates; (h) < &hstates[max_hstate]; (h)++)
@@ -1208,6 +1208,8 @@ static int __init hugetlb_init(void)
 {
 	BUILD_BUG_ON(HPAGE_SHIFT == 0);
 
+	default_hstate_size = HPAGE_SIZE;
+
 	if (!size_to_hstate(default_hstate_size)) {
 		default_hstate_size = HPAGE_SIZE;
 		if (!size_to_hstate(default_hstate_size))
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
