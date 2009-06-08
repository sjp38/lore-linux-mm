Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 02A296B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 09:06:48 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 4so2059735qwk.44
        for <linux-mm@kvack.org>; Mon, 08 Jun 2009 07:25:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090608132950.GB15070@csn.ul.ie>
References: <20090608132950.GB15070@csn.ul.ie>
Date: Mon, 8 Jun 2009 23:25:08 +0900
Message-ID: <28c262360906080725o1e6d9e93t465ffeb53b093a17@mail.gmail.com>
Subject: Re: [PATCH] Add a gfp-translate script to help understand page
	allocation failure reports
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, Mel.

How about handling it in kernel itself ?

I mean we can print human-readable pretty format instead of
non-understandable hex value. It can help us without knowing other's
people's machine configuration.

BTW, It would be better than now by your script.
Thanks for sharing good tip. :)

On Mon, Jun 8, 2009 at 10:29 PM, Mel Gorman<mel@csn.ul.ie> wrote:
> The page allocation failure messages include a line that looks like
>
> page allocation failure. order:1, mode:0x4020
>
> The mode is easy to translate but irritating for the lazy and a bit error
> prone. This patch adds a very simple helper script gfp-translate for the =
mode:
> portion of the page allocation failure messages. An example usage looks l=
ike
>
> =C2=A0mel@machina:~/linux-2.6 $ scripts/gfp-translate 0x4020
> =C2=A0Source: /home/mel/linux-2.6
> =C2=A0Parsing: 0x4020
> =C2=A0#define __GFP_HIGH =C2=A0 =C2=A0(0x20) =C2=A0/* Should access emerg=
ency pools? */
> =C2=A0#define __GFP_COMP =C2=A0 =C2=A0(0x4000) /* Add compound page metad=
ata */
>
> The script is not a work of art but it has come in handy for me a few tim=
es
> so I thought I would share.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
> =C2=A0scripts/gfp-translate | =C2=A0 81 +++++++++++++++++++++++++++++++++=
+++++++++++++++++
> =C2=A01 file changed, 81 insertions(+)
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
> +SOURCE=3D
> +GFPMASK=3Dnone
> +
> +# Helper function to report failures and exit
> +die() {
> + =C2=A0 =C2=A0 =C2=A0 echo ERROR: $@
> + =C2=A0 =C2=A0 =C2=A0 if [ "$TMPFILE" !=3D "" ]; then
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rm -f $TMPFILE
> + =C2=A0 =C2=A0 =C2=A0 fi
> + =C2=A0 =C2=A0 =C2=A0 exit -1
> +}
> +
> +usage() {
> + =C2=A0 =C2=A0 =C2=A0 echo "usage: gfp-translate [-h] [ --source DIRECTO=
RY ] gfpmask"
> + =C2=A0 =C2=A0 =C2=A0 exit 0
> +}
> +
> +# Parse command-line arguements
> +while [ $# -gt 0 ]; do
> + =C2=A0 =C2=A0 =C2=A0 case $1 in
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 --source)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 SOURCE=3D$2
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 shift 2
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ;;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -h)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 usage
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ;;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 --help)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 usage
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ;;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 GFPMASK=3D$1
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 shift
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ;;
> + =C2=A0 =C2=A0 =C2=A0 esac
> +done
> +
> +# Guess the kernel source directory if it's not set. Preference is in or=
der of
> +# o current directory
> +# o /usr/src/linux
> +if [ "$SOURCE" =3D "" ]; then
> + =C2=A0 =C2=A0 =C2=A0 if [ -r "/usr/src/linux/Makefile" ]; then
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SOURCE=3D/usr/src/linu=
x
> + =C2=A0 =C2=A0 =C2=A0 fi
> + =C2=A0 =C2=A0 =C2=A0 if [ -r "`pwd`/Makefile" ]; then
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SOURCE=3D`pwd`
> + =C2=A0 =C2=A0 =C2=A0 fi
> +fi
> +
> +# Confirm that a source directory exists
> +if [ ! -r "$SOURCE/Makefile" ]; then
> + =C2=A0 =C2=A0 =C2=A0 die "Could not locate source directory or it is in=
valid"
> +fi
> +
> +# Confirm that a GFP mask has been specified
> +if [ "$GFPMASK" =3D "none" ]; then
> + =C2=A0 =C2=A0 =C2=A0 usage
> +fi
> +
> +# Extract GFP flags from the kernel source
> +TMPFILE=3D`mktemp -t gfptranslate-XXXXXX` || exit 1
> +grep "^#define __GFP" $SOURCE/include/linux/gfp.h | sed -e 's/(__force g=
fp_t)//' | sed -e 's/u)/)/' | grep -v GFP_BITS | sed -e 's/)\//) \//' > $TM=
PFILE
> +
> +# Parse the flags
> +IFS=3D"
> +"
> +echo Source: $SOURCE
> +echo Parsing: $GFPMASK
> +for LINE in `cat $TMPFILE`; do
> + =C2=A0 =C2=A0 =C2=A0 MASK=3D`echo $LINE | awk '{print $3}'`
> + =C2=A0 =C2=A0 =C2=A0 if [ $(($GFPMASK&$MASK)) -ne 0 ]; then
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 echo $LINE
> + =C2=A0 =C2=A0 =C2=A0 fi
> +done
> +
> +rm -f $TMPFILE
> +exit 0
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>


--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
