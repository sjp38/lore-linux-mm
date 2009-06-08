Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A6C886B004F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 08:42:00 -0400 (EDT)
Date: Mon, 8 Jun 2009 09:59:06 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Add a gfp-translate script to help understand page
	allocation failure reports
Message-ID: <20090608135906.GA6027@infradead.org>
References: <20090608132950.GB15070@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090608132950.GB15070@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 02:29:50PM +0100, Mel Gorman wrote:
> The page allocation failure messages include a line that looks like
> 
> page allocation failure. order:1, mode:0x4020
> 
> The mode is easy to translate but irritating for the lazy and a bit error
> prone. This patch adds a very simple helper script gfp-translate for the mode:
> portion of the page allocation failure messages. An example usage looks like

Maybe we just just print the symbolic flags directly?  The even tracer
in the for-2.6.23 queue now has a __print_flags helper to translate the
bitmask back into symbolic flags, and we even have a kmalloc tracer
using it for the GFP flags.  Maybe we should add a printk_flags variant
for regular printks and just do the right thing?

> 
>   mel@machina:~/linux-2.6 $ scripts/gfp-translate 0x4020
>   Source: /home/mel/linux-2.6
>   Parsing: 0x4020
>   #define __GFP_HIGH	(0x20)	/* Should access emergency pools? */
>   #define __GFP_COMP	(0x4000) /* Add compound page metadata */
> 
> The script is not a work of art but it has come in handy for me a few times
> so I thought I would share.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> --- 
>  scripts/gfp-translate |   81 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 81 insertions(+)
> 
> diff --git a/scripts/gfp-translate b/scripts/gfp-translate
> new file mode 100755
> index 0000000..724db2d
> --- /dev/null
> +++ b/scripts/gfp-translate
> @@ -0,0 +1,81 @@
> +#!/bin/bash
> +# Translate the bits making up a GFP mask
> +# (c) 2009, Mel Gorman <mel@csn.ul.ie>
> +# Licensed under the terms of the GNU GPL License version 2
> +SOURCE=
> +GFPMASK=none
> +
> +# Helper function to report failures and exit
> +die() {
> +	echo ERROR: $@
> +	if [ "$TMPFILE" != "" ]; then
> +		rm -f $TMPFILE
> +	fi
> +	exit -1
> +}
> +
> +usage() {
> +	echo "usage: gfp-translate [-h] [ --source DIRECTORY ] gfpmask"
> +	exit 0
> +}
> +
> +# Parse command-line arguements
> +while [ $# -gt 0 ]; do
> +	case $1 in
> +		--source)
> +			SOURCE=$2
> +			shift 2
> +			;;
> +		-h)
> +			usage
> +			;;
> +		--help)
> +			usage
> +			;;
> +		*)
> +			GFPMASK=$1
> +			shift
> +			;;
> +	esac
> +done
> +
> +# Guess the kernel source directory if it's not set. Preference is in order of
> +# o current directory
> +# o /usr/src/linux
> +if [ "$SOURCE" = "" ]; then
> +	if [ -r "/usr/src/linux/Makefile" ]; then
> +		SOURCE=/usr/src/linux
> +	fi
> +	if [ -r "`pwd`/Makefile" ]; then
> +		SOURCE=`pwd`
> +	fi
> +fi
> +
> +# Confirm that a source directory exists
> +if [ ! -r "$SOURCE/Makefile" ]; then
> +	die "Could not locate source directory or it is invalid"
> +fi
> +
> +# Confirm that a GFP mask has been specified
> +if [ "$GFPMASK" = "none" ]; then
> +	usage
> +fi
> +
> +# Extract GFP flags from the kernel source
> +TMPFILE=`mktemp -t gfptranslate-XXXXXX` || exit 1
> +grep "^#define __GFP" $SOURCE/include/linux/gfp.h | sed -e 's/(__force gfp_t)//' | sed -e 's/u)/)/' | grep -v GFP_BITS | sed -e 's/)\//) \//' > $TMPFILE
> +
> +# Parse the flags
> +IFS="
> +"
> +echo Source: $SOURCE
> +echo Parsing: $GFPMASK
> +for LINE in `cat $TMPFILE`; do
> +	MASK=`echo $LINE | awk '{print $3}'`
> +	if [ $(($GFPMASK&$MASK)) -ne 0 ]; then
> +		echo $LINE
> +	fi
> +done
> +
> +rm -f $TMPFILE
> +exit 0
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
