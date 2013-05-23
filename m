Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 49A9E6B0032
	for <linux-mm@kvack.org>; Thu, 23 May 2013 17:46:58 -0400 (EDT)
Date: Thu, 23 May 2013 14:46:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 2/9] vmcore: allocate buffer for ELF headers on
 page-size alignment
Message-Id: <20130523144655.80cf1fd9622aae3fc7ec4161@linux-foundation.org>
In-Reply-To: <20130523052507.13864.61820.stgit@localhost6.localdomain6>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
	<20130523052507.13864.61820.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: vgoyal@redhat.com, ebiederm@xmission.com, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Thu, 23 May 2013 14:25:07 +0900 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com> wrote:

> Allocate ELF headers on page-size boundary using __get_free_pages()
> instead of kmalloc().
> 
> Later patch will merge PT_NOTE entries into a single unique one and
> decrease the buffer size actually used. Keep original buffer size in
> variable elfcorebuf_sz_orig to kfree the buffer later and actually
> used buffer size with rounded up to page-size boundary in variable
> elfcorebuf_sz separately.
> 
> The size of part of the ELF buffer exported from /proc/vmcore is
> elfcorebuf_sz.
> 
> The merged, removed PT_NOTE entries, i.e. the range [elfcorebuf_sz,
> elfcorebuf_sz_orig], is filled with 0.
> 
> Use size of the ELF headers as an initial offset value in
> set_vmcore_list_offsets_elf{64,32} and
> process_ptload_program_headers_elf{64,32} in order to indicate that
> the offset includes the holes towards the page boundary.
> 
> As a result, both set_vmcore_list_offsets_elf{64,32} have the same
> definition. Merge them as set_vmcore_list_offsets.
> 
> ...
>
> @@ -526,30 +505,35 @@ static int __init parse_crash_elf64_headers(void)
>  	}
>  
>  	/* Read in all elf headers. */
> -	elfcorebuf_sz = sizeof(Elf64_Ehdr) + ehdr.e_phnum * sizeof(Elf64_Phdr);
> -	elfcorebuf = kmalloc(elfcorebuf_sz, GFP_KERNEL);
> +	elfcorebuf_sz_orig = sizeof(Elf64_Ehdr) + ehdr.e_phnum * sizeof(Elf64_Phdr);
> +	elfcorebuf_sz = elfcorebuf_sz_orig;
> +	elfcorebuf = (void *) __get_free_pages(GFP_KERNEL | __GFP_ZERO,
> +					       get_order(elfcorebuf_sz_orig));
>  	if (!elfcorebuf)
>  		return -ENOMEM;
>  	addr = elfcorehdr_addr;
> -	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz, &addr, 0);
> +	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz_orig, &addr, 0);
>  	if (rc < 0) {
> -		kfree(elfcorebuf);
> +		free_pages((unsigned long)elfcorebuf,
> +			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
>  
>  	/* Merge all PT_NOTE headers into one. */
>  	rc = merge_note_headers_elf64(elfcorebuf, &elfcorebuf_sz, &vmcore_list);
>  	if (rc) {
> -		kfree(elfcorebuf);
> +		free_pages((unsigned long)elfcorebuf,
> +			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
>  	rc = process_ptload_program_headers_elf64(elfcorebuf, elfcorebuf_sz,
>  							&vmcore_list);
>  	if (rc) {
> -		kfree(elfcorebuf);
> +		free_pages((unsigned long)elfcorebuf,
> +			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
> -	set_vmcore_list_offsets_elf64(elfcorebuf, &vmcore_list);
> +	set_vmcore_list_offsets(elfcorebuf_sz, &vmcore_list);
>  	return 0;
>  }
>  
> @@ -581,30 +565,35 @@ static int __init parse_crash_elf32_headers(void)
>  	}
>  
>  	/* Read in all elf headers. */
> -	elfcorebuf_sz = sizeof(Elf32_Ehdr) + ehdr.e_phnum * sizeof(Elf32_Phdr);
> -	elfcorebuf = kmalloc(elfcorebuf_sz, GFP_KERNEL);
> +	elfcorebuf_sz_orig = sizeof(Elf32_Ehdr) + ehdr.e_phnum * sizeof(Elf32_Phdr);
> +	elfcorebuf_sz = elfcorebuf_sz_orig;
> +	elfcorebuf = (void *) __get_free_pages(GFP_KERNEL | __GFP_ZERO,
> +					       get_order(elfcorebuf_sz_orig));
>  	if (!elfcorebuf)
>  		return -ENOMEM;
>  	addr = elfcorehdr_addr;
> -	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz, &addr, 0);
> +	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz_orig, &addr, 0);
>  	if (rc < 0) {
> -		kfree(elfcorebuf);
> +		free_pages((unsigned long)elfcorebuf,
> +			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
>  
>  	/* Merge all PT_NOTE headers into one. */
>  	rc = merge_note_headers_elf32(elfcorebuf, &elfcorebuf_sz, &vmcore_list);
>  	if (rc) {
> -		kfree(elfcorebuf);
> +		free_pages((unsigned long)elfcorebuf,
> +			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
>  	rc = process_ptload_program_headers_elf32(elfcorebuf, elfcorebuf_sz,
>  								&vmcore_list);
>  	if (rc) {
> -		kfree(elfcorebuf);
> +		free_pages((unsigned long)elfcorebuf,
> +			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
> -	set_vmcore_list_offsets_elf32(elfcorebuf, &vmcore_list);
> +	set_vmcore_list_offsets(elfcorebuf_sz, &vmcore_list);
>  	return 0;
>  }
>  
> @@ -629,14 +618,14 @@ static int __init parse_crash_elf_headers(void)
>  			return rc;
>  
>  		/* Determine vmcore size. */
> -		vmcore_size = get_vmcore_size_elf64(elfcorebuf);
> +		vmcore_size = get_vmcore_size_elf64(elfcorebuf, elfcorebuf_sz);
>  	} else if (e_ident[EI_CLASS] == ELFCLASS32) {
>  		rc = parse_crash_elf32_headers();
>  		if (rc)
>  			return rc;
>  
>  		/* Determine vmcore size. */
> -		vmcore_size = get_vmcore_size_elf32(elfcorebuf);
> +		vmcore_size = get_vmcore_size_elf32(elfcorebuf, elfcorebuf_sz);
>  	} else {
>  		pr_warn("Warning: Core image elf header is not sane\n");
>  		return -EINVAL;
> @@ -683,7 +672,8 @@ void vmcore_cleanup(void)
>  		list_del(&m->list);
>  		kfree(m);
>  	}
> -	kfree(elfcorebuf);
> +	free_pages((unsigned long)elfcorebuf,
> +		   get_order(elfcorebuf_sz_orig));
>  	elfcorebuf = NULL;
>  }

- the amount of code duplication is excessive

- the code sometimes leaves elfcorebuf==NULL and sometimes doesn't.

Please review and test this cleanup:

--- a/fs/proc/vmcore.c~vmcore-allocate-buffer-for-elf-headers-on-page-size-alignment-fix
+++ a/fs/proc/vmcore.c
@@ -477,6 +477,12 @@ static void __init set_vmcore_list_offse
 	}
 }
 
+static void free_elfcorebuf(void)
+{
+	free_pages((unsigned long)elfcorebuf, get_order(elfcorebuf_sz_orig));
+	elfcorebuf = NULL;
+}
+
 static int __init parse_crash_elf64_headers(void)
 {
 	int rc=0;
@@ -505,36 +511,31 @@ static int __init parse_crash_elf64_head
 	}
 
 	/* Read in all elf headers. */
-	elfcorebuf_sz_orig = sizeof(Elf64_Ehdr) + ehdr.e_phnum * sizeof(Elf64_Phdr);
+	elfcorebuf_sz_orig = sizeof(Elf64_Ehdr) +
+				ehdr.e_phnum * sizeof(Elf64_Phdr);
 	elfcorebuf_sz = elfcorebuf_sz_orig;
-	elfcorebuf = (void *) __get_free_pages(GFP_KERNEL | __GFP_ZERO,
-					       get_order(elfcorebuf_sz_orig));
+	elfcorebuf = (void *)__get_free_pages(GFP_KERNEL | __GFP_ZERO,
+					      get_order(elfcorebuf_sz_orig));
 	if (!elfcorebuf)
 		return -ENOMEM;
 	addr = elfcorehdr_addr;
 	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz_orig, &addr, 0);
-	if (rc < 0) {
-		free_pages((unsigned long)elfcorebuf,
-			   get_order(elfcorebuf_sz_orig));
-		return rc;
-	}
+	if (rc < 0)
+		goto fail;
 
 	/* Merge all PT_NOTE headers into one. */
 	rc = merge_note_headers_elf64(elfcorebuf, &elfcorebuf_sz, &vmcore_list);
-	if (rc) {
-		free_pages((unsigned long)elfcorebuf,
-			   get_order(elfcorebuf_sz_orig));
-		return rc;
-	}
+	if (rc)
+		goto fail;
 	rc = process_ptload_program_headers_elf64(elfcorebuf, elfcorebuf_sz,
 							&vmcore_list);
-	if (rc) {
-		free_pages((unsigned long)elfcorebuf,
-			   get_order(elfcorebuf_sz_orig));
-		return rc;
-	}
+	if (rc)
+		goto fail;
 	set_vmcore_list_offsets(elfcorebuf_sz, &vmcore_list);
 	return 0;
+fail:
+	free_elfcorebuf();
+	return rc;
 }
 
 static int __init parse_crash_elf32_headers(void)
@@ -567,34 +568,28 @@ static int __init parse_crash_elf32_head
 	/* Read in all elf headers. */
 	elfcorebuf_sz_orig = sizeof(Elf32_Ehdr) + ehdr.e_phnum * sizeof(Elf32_Phdr);
 	elfcorebuf_sz = elfcorebuf_sz_orig;
-	elfcorebuf = (void *) __get_free_pages(GFP_KERNEL | __GFP_ZERO,
-					       get_order(elfcorebuf_sz_orig));
+	elfcorebuf = (void *)__get_free_pages(GFP_KERNEL | __GFP_ZERO,
+					      get_order(elfcorebuf_sz_orig));
 	if (!elfcorebuf)
 		return -ENOMEM;
 	addr = elfcorehdr_addr;
 	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz_orig, &addr, 0);
-	if (rc < 0) {
-		free_pages((unsigned long)elfcorebuf,
-			   get_order(elfcorebuf_sz_orig));
-		return rc;
-	}
+	if (rc < 0)
+		goto fail;
 
 	/* Merge all PT_NOTE headers into one. */
 	rc = merge_note_headers_elf32(elfcorebuf, &elfcorebuf_sz, &vmcore_list);
-	if (rc) {
-		free_pages((unsigned long)elfcorebuf,
-			   get_order(elfcorebuf_sz_orig));
-		return rc;
-	}
+	if (rc)
+		goto fail;
 	rc = process_ptload_program_headers_elf32(elfcorebuf, elfcorebuf_sz,
 								&vmcore_list);
-	if (rc) {
-		free_pages((unsigned long)elfcorebuf,
-			   get_order(elfcorebuf_sz_orig));
-		return rc;
-	}
+	if (rc)
+		goto fail;
 	set_vmcore_list_offsets(elfcorebuf_sz, &vmcore_list);
 	return 0;
+fail:
+	free_elfcorebuf();
+	return rc;
 }
 
 static int __init parse_crash_elf_headers(void)
@@ -672,8 +667,6 @@ void vmcore_cleanup(void)
 		list_del(&m->list);
 		kfree(m);
 	}
-	free_pages((unsigned long)elfcorebuf,
-		   get_order(elfcorebuf_sz_orig));
-	elfcorebuf = NULL;
+	free_elfcorebuf();
 }
 EXPORT_SYMBOL_GPL(vmcore_cleanup);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
