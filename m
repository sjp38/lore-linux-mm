Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 0AD546B00A8
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 16:08:16 -0400 (EDT)
Date: Mon, 1 Oct 2012 13:08:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Avoid section mismatch warning for
 memblock_type_name.
Message-Id: <20121001130815.d7602ff5.akpm@linux-foundation.org>
In-Reply-To: <be1027442539398a9cdce6284d1e2534a27644ae.1348829645.git.rprabhu@wnohang.net>
References: <be1027442539398a9cdce6284d1e2534a27644ae.1348829645.git.rprabhu@wnohang.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: raghu.prabhu13@gmail.com
Cc: linux-mm@kvack.org, tj@kernel.org, benh@kernel.crashing.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

On Fri, 28 Sep 2012 16:46:44 +0530
raghu.prabhu13@gmail.com wrote:

> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> 
> Following section mismatch warning is thrown during build;
> 
>     WARNING: vmlinux.o(.text+0x32408f): Section mismatch in reference from the function memblock_type_name() to the variable .meminit.data:memblock
>     The function memblock_type_name() references
>     the variable __meminitdata memblock.
>     This is often because memblock_type_name lacks a __meminitdata
>     annotation or the annotation of memblock is wrong.
> 
> This is because memblock_type_name makes reference to memblock variable with
> attribute __meminitdata. Hence, the warning (even if the function is inline).
> 
> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
> ---
>  mm/memblock.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 82aa349..8e7fb1f 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -41,7 +41,8 @@ static int memblock_memory_in_slab __initdata_memblock = 0;
>  static int memblock_reserved_in_slab __initdata_memblock = 0;
>  
>  /* inline so we don't get a warning when pr_debug is compiled out */
> -static inline const char *memblock_type_name(struct memblock_type *type)
> +static inline __init_memblock
> +		const char *memblock_type_name(struct memblock_type *type)
>  {
>  	if (type == &memblock.memory)
>  		return "memory";

huh.  If your compiler inlines that function, you won't get the
warning.  Another reason why inline-considered-harmful nowadays.  Let's
just nuke it.

Also, please note the code layout issue.  There are two ways we'll
typically handle a definition like that:

static inline __init_memblock const char *memblock_type_name(struct memblock_type *type)

or

static inline __init_memblock const char *
memblock_type_name(struct memblock_type *type)


You chose neither ;)

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-avoid-section-mismatch-warning-for-memblock_type_name-fix

remove inline

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Raghavendra D Prabhu <rprabhu@wnohang.net>
Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memblock.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN mm/memblock.c~mm-avoid-section-mismatch-warning-for-memblock_type_name-fix mm/memblock.c
--- a/mm/memblock.c~mm-avoid-section-mismatch-warning-for-memblock_type_name-fix
+++ a/mm/memblock.c
@@ -41,8 +41,8 @@ static int memblock_memory_in_slab __ini
 static int memblock_reserved_in_slab __initdata_memblock = 0;
 
 /* inline so we don't get a warning when pr_debug is compiled out */
-static inline __init_memblock
-		const char *memblock_type_name(struct memblock_type *type)
+static __init_memblock const char *
+memblock_type_name(struct memblock_type *type)
 {
 	if (type == &memblock.memory)
 		return "memory";
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
