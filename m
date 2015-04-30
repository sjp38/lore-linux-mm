Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id D62CD6B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 11:39:45 -0400 (EDT)
Received: by widdi4 with SMTP id di4so24670139wid.0
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 08:39:45 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id fw6si3427217wib.35.2015.04.30.08.39.43
        for <linux-mm@kvack.org>;
        Thu, 30 Apr 2015 08:39:43 -0700 (PDT)
Date: Thu, 30 Apr 2015 18:39:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 01/11] mm: debug: format flags in a buffer
Message-ID: <20150430153940.GA17156@node.dhcp.inet.fi>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
 <1429044993-1677-2-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429044993-1677-2-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, Apr 14, 2015 at 04:56:23PM -0400, Sasha Levin wrote:
> Format various flags to a string buffer rather than printing them. This is
> a helper for later.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  mm/debug.c |   35 +++++++++++++++++++++++++++++++++++
>  1 file changed, 35 insertions(+)
> 
> diff --git a/mm/debug.c b/mm/debug.c
> index 3eb3ac2..c9f7dd7 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -80,6 +80,41 @@ static void dump_flags(unsigned long flags,
>  	pr_cont(")\n");
>  }
>  
> +static char *format_flags(unsigned long flags,
> +			const struct trace_print_flags *names, int count,
> +			char *buf, char *end)
> +{
> +	const char *delim = "";
> +	unsigned long mask;
> +	int i;
> +
> +	buf += snprintf(buf, (buf > end ? 0 : end - buf),
> +				"flags: %#lx(", flags);
> +
> +	/* remove zone id */
> +	flags &= (1UL << NR_PAGEFLAGS) - 1;
> +
> +	for (i = 0; i < count && flags; i++) {
> +                mask = names[i].mask;
> +                if ((flags & mask) != mask)
> +                        continue;
> +
> +                flags &= ~mask;
> +		buf += snprintf(buf, (buf > end ? 0 : end - buf),
> +                		"%s%s", delim, names[i].name);

Indent is off. Otherwise look okay to me.

> +                delim = "|";
> +        }
> +
> +        /* check for left over flags */
> +        if (flags)
> +		buf += snprintf(buf, (buf > end ? 0 : end - buf),
> +                		"%s%#lx", delim, flags);
> +
> +	buf += snprintf(buf, (buf > end ? 0 : end - buf), ")\n");
> +
> +	return buf;
> +}
> +
>  void dump_page_badflags(struct page *page, const char *reason,
>  		unsigned long badflags)
>  {
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
