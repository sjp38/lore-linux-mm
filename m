Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id CA2A26B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 12:17:32 -0400 (EDT)
Received: by wgen6 with SMTP id n6so68026489wge.3
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 09:17:32 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id cr5si4682512wjb.214.2015.04.30.09.17.30
        for <linux-mm@kvack.org>;
        Thu, 30 Apr 2015 09:17:30 -0700 (PDT)
Date: Thu, 30 Apr 2015 19:17:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 02/11] mm: debug: deal with a new family of MM pointers
Message-ID: <20150430161728.GA17344@node.dhcp.inet.fi>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
 <1429044993-1677-3-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429044993-1677-3-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, Apr 14, 2015 at 04:56:24PM -0400, Sasha Levin wrote:
> This teaches our printing functions about a new family of MM pointer that it
> could now print.
> 
> I've picked %pZ because %pm and %pM were already taken, so I figured it
> doesn't really matter what we go with. We also have the option of stealing
> one of those two...
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  lib/vsprintf.c |   13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index 8243e2f..809d19d 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -1375,6 +1375,16 @@ char *comm_name(char *buf, char *end, struct task_struct *tsk,
>  	return string(buf, end, name, spec);
>  }
>  
> +static noinline_for_stack
> +char *mm_pointer(char *buf, char *end, struct task_struct *tsk,
> +		struct printf_spec spec, const char *fmt)
> +{
> +	switch (fmt[1]) {

shouldn't we printout at least pointer address for unknown suffixes?

> +	}
> +
> +	return buf;
> +}
> +
>  int kptr_restrict __read_mostly;
>  
>  /*
> @@ -1463,6 +1473,7 @@ int kptr_restrict __read_mostly;
>   *        (legacy clock framework) of the clock
>   * - 'Cr' For a clock, it prints the current rate of the clock
>   * - 'T' task_struct->comm
> + * - 'Z' Outputs a readable version of a type of memory management struct.
>   *
>   * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
>   * function pointers are really function descriptors, which contain a
> @@ -1615,6 +1626,8 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
>  				   spec, fmt);
>  	case 'T':
>  		return comm_name(buf, end, ptr, spec, fmt);
> +	case 'Z':
> +		return mm_pointer(buf, end, ptr, spec, fmt);
>  	}
>  	spec.flags |= SMALL;
>  	if (spec.field_width == -1) {
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
