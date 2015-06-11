Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB1C6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 05:41:49 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so1562217wgb.3
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 02:41:48 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id m11si15193871wiw.95.2015.06.11.02.41.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 02:41:47 -0700 (PDT)
Date: Thu, 11 Jun 2015 11:41:36 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH V2] checkpatch: Add some <foo>_destroy functions to
 NEEDLESS_IF tests
In-Reply-To: <1433915549.2730.107.camel@perches.com>
Message-ID: <alpine.DEB.2.10.1506111140240.2320@hadrien>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>  <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>  <1433894769.2730.87.camel@perches.com>  <1433911166.2730.98.camel@perches.com>
 <1433915549.2730.107.camel@perches.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Julia Lawall <julia.lawall@lip6.fr>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com



On Tue, 9 Jun 2015, Joe Perches wrote:

> Sergey Senozhatsky has modified several destroy functions that can
> now be called with NULL values.
>
>  - kmem_cache_destroy()
>  - mempool_destroy()
>  - dma_pool_destroy()

I don't actually see any null test in the definition of dma_pool_destroy,
in the linux-next 54896f27dd5 (20150610).  So I guess it would be
premature to send patches to remove the null tests.

julia

> Update checkpatch to warn when those functions are preceded by an if.
>
> Update checkpatch to --fix all the calls too only when the code style
> form is using leading tabs.
>
> from:
> 	if (foo)
> 		<func>(foo);
> to:
> 	<func>(foo);
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> V2: Remove useless debugging print messages and multiple quotemetas
>
>  scripts/checkpatch.pl | 32 ++++++++++++++++++++++++++++----
>  1 file changed, 28 insertions(+), 4 deletions(-)
>
> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> index 69c4716..87d3bf1aa 100755
> --- a/scripts/checkpatch.pl
> +++ b/scripts/checkpatch.pl
> @@ -4800,10 +4800,34 @@ sub process {
>
>  # check for needless "if (<foo>) fn(<foo>)" uses
>  		if ($prevline =~ /\bif\s*\(\s*($Lval)\s*\)/) {
> -			my $expr = '\s*\(\s*' . quotemeta($1) . '\s*\)\s*;';
> -			if ($line =~ /\b(kfree|usb_free_urb|debugfs_remove(?:_recursive)?)$expr/) {
> -				WARN('NEEDLESS_IF',
> -				     "$1(NULL) is safe and this check is probably not required\n" . $hereprev);
> +			my $tested = quotemeta($1);
> +			my $expr = '\s*\(\s*' . $tested . '\s*\)\s*;';
> +			if ($line =~ /\b(kfree|usb_free_urb|debugfs_remove(?:_recursive)?|(?:kmem_cache|mempool|dma_pool)_destroy)$expr/) {
> +				my $func = $1;
> +				if (WARN('NEEDLESS_IF',
> +					 "$func(NULL) is safe and this check is probably not required\n" . $hereprev) &&
> +				    $fix) {
> +					my $do_fix = 1;
> +					my $leading_tabs = "";
> +					my $new_leading_tabs = "";
> +					if ($lines[$linenr - 2] =~ /^\+(\t*)if\s*\(\s*$tested\s*\)\s*$/) {
> +						$leading_tabs = $1;
> +					} else {
> +						$do_fix = 0;
> +					}
> +					if ($lines[$linenr - 1] =~ /^\+(\t+)$func\s*\(\s*$tested\s*\)\s*;\s*$/) {
> +						$new_leading_tabs = $1;
> +						if (length($leading_tabs) + 1 ne length($new_leading_tabs)) {
> +							$do_fix = 0;
> +						}
> +					} else {
> +						$do_fix = 0;
> +					}
> +					if ($do_fix) {
> +						fix_delete_line($fixlinenr - 1, $prevrawline);
> +						$fixed[$fixlinenr] =~ s/^\+$new_leading_tabs/\+$leading_tabs/;
> +					}
> +				}
>  			}
>  		}
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
