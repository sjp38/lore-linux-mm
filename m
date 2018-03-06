Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EEFAD6B000D
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 17:48:26 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c142so264609wmh.4
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 14:48:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 141si7009750wmr.72.2018.03.06.14.48.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 14:48:25 -0800 (PST)
Date: Tue, 6 Mar 2018 14:48:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 09/11] mm: Allow arch code to override
 copy_highpage()
Message-Id: <20180306144819.53e794acc83309fd8b401e92@linux-foundation.org>
In-Reply-To: <ecbafa2bfcc05f22183be2e7784ed11943b1d5b2.1519227112.git.khalid.aziz@oracle.com>
References: <cover.1519227112.git.khalid.aziz@oracle.com>
	<ecbafa2bfcc05f22183be2e7784ed11943b1d5b2.1519227112.git.khalid.aziz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: davem@davemloft.net, dave.hansen@linux.intel.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, tglx@linutronix.de, anthony.yznaga@oracle.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On Wed, 21 Feb 2018 10:15:51 -0700 Khalid Aziz <khalid.aziz@oracle.com> wrote:

> Some architectures can support metadata for memory pages and when a
> page is copied, its metadata must also be copied. Sparc processors
> from M7 onwards support metadata for memory pages. This metadata
> provides tag based protection for access to memory pages. To maintain
> this protection, the tag data must be copied to the new page when a
> page is migrated across NUMA nodes. This patch allows arch specific
> code to override default copy_highpage() and copy metadata along
> with page data upon migration.
> 
> ...
>
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -237,6 +237,8 @@ static inline void copy_user_highpage(struct page *to, struct page *from,
>  
>  #endif
>  
> +#ifndef __HAVE_ARCH_COPY_HIGHPAGE
> +
>  static inline void copy_highpage(struct page *to, struct page *from)
>  {
>  	char *vfrom, *vto;
> @@ -248,4 +250,6 @@ static inline void copy_highpage(struct page *to, struct page *from)
>  	kunmap_atomic(vfrom);
>  }
>  
> +#endif
> +
>  #endif /* _LINUX_HIGHMEM_H */

It would be more consistent and conventional here to do

#ifndef copy_highpage
static inline void copy_highpage(struct page *to, struct page *from)
{
	...
}
#define copy_highpage copy_highpage

As is happening in [patch 07/11].

And a similar change could be made to [patch 02/11], actually.


Either way,

Acked-by: Andrew Morton <akpm@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
