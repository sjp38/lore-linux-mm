Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 3D2426B00EA
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 14:09:30 -0500 (EST)
Received: by dadv6 with SMTP id v6so2887786dad.14
        for <linux-mm@kvack.org>; Thu, 16 Feb 2012 11:09:29 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 01/18] Added hacking menu for override optimization by
 GCC.
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
Date: Thu, 16 Feb 2012 11:09:18 -0800
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v9sctsrj3l0zgt@mpn-glaptop>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, =?utf-8?B?UmFkb3PFgmF3IFNtb2d1cmE=?= <mail@smogura.eu>
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, linux-ext4@vger.kernel.org

On Thu, 16 Feb 2012 06:31:28 -0800, Rados=C5=82aw Smogura <mail@smogura.=
eu> wrote:
> Supporting files, like Kconfig, Makefile are auto-generated due to lar=
ge amount
> of available options.

So why not run the script as part of make rather then store generated fi=
les in
repository?

> diff --git a/scripts/debug/make_config_optim.sh b/scripts/debug/make_c=
onfig_optim.sh
> new file mode 100644
> index 0000000..26865923
> --- /dev/null
> +++ b/scripts/debug/make_config_optim.sh
> @@ -0,0 +1,88 @@
> +#!/bin/sh

The below won't run on POSIX-compatible sh.  Address my comments
below to fix that.

> +
> +## Utility script for generating optimization override options
> +## for kernel compilation.
> +##
> +## Distributed under GPL v2 license
> +## (c) Rados=C5=82aw Smogura, 2011
> +
> +# Prefix added for variable
> +CFG_PREFIX=3D"HACK_OPTIM"
> +
> +KCFG=3D"Kconfig.debug.optim"
> +MKFI=3D"Makefile.optim.inc"

How about names that mean something?

KCONFIG=3D...
MAKEFILE=3D...

> +
> +OPTIMIZATIONS_PARAMS=3D"-fno-inline-functions-called-once \
> + -fno-combine-stack-adjustments \
> + -fno-tree-dce \
> + -fno-tree-dominator-opts \
> + -fno-dse "

Slashes at end of lines are not necessary here.

> +
> +echo "# This file was auto generated. It's utility configuration" > $=
KCFG
> +echo "# Distributed under GPL v2 License" >> $KCFG
> +echo >> $KCFG
> +echo "menuconfig ${CFG_PREFIX}" >> $KCFG
> +echo -e "\tbool \"Allows to override GCC optimization\"" >> $KCFG
> +echo -e "\tdepends on DEBUG_KERNEL && EXPERIMENTAL" >> $KCFG
> +echo -e "\thelp" >> $KCFG
> +echo -e "\t  If you say Y here you will be able to override" >> $KCFG=

> +echo -e "\t  how GCC optimize kernel code. This will create" >> $KCFG=

> +echo -e "\t  more debug friendly, but with not guarentee"    >> $KCFG=

> +echo -e "\t  about same runi, like production, kernel."      >> $KCFG=

> +echo >> $KCFG
> +echo -e "\t  If you say Y here probably You will want say"   >> $KCFG=

> +echo -e "\t  for all suboptions" >> $KCFG
> +echo >> $KCFG
> +echo "if ${CFG_PREFIX}" >> $KCFG
> +echo >> $KCFG

Use:

cat > $KCFG <<EOF
...
EOF

through the file (of course, in next runs you'll need to use =E2=80=9C>>=
 $KCFG=E2=80=9D).
More readable and also =E2=80=9C-e=E2=80=9D argument to echo is bash-spe=
cific.

Alternatively to using =E2=80=9C> $KCFG=E2=80=9D all the time, you can a=
lso do:

	exec 3> Kconfig.debug.optim
	exec 4> Makefile.optim.inc

at the beginning of the script and later use >&3 and >&4, which will sav=
e
you some open/close calls and make the strangely named $KCFG and $MKFI
variables no longer needed.

> +
> +echo "# This file was auto generated. It's utility configuration" > $=
MKFI
> +echo "# Distributed under GPL v2 License" >> $MKFI
> +echo >> $MKFI
> +
> +# Insert standard override optimization level
> +# This is exception, and this value will not be included
> +# in auto generated makefile. Support for this value
> +# is hard coded in main Makefile.
> +echo -e "config ${CFG_PREFIX}_FORCE_O1_LEVEL" >> $KCFG
> +echo -e "\tbool \"Forces -O1 optimization level\"" >> $KCFG
> +echo -e "\t---help---" >> $KCFG
> +echo -e "\t  This will change how GCC optimize code. Code" >> $KCFG
> +echo -e "\t  may be slower and larger but will be more debug" >> $KCF=
G
> +echo -e "\t  \"friendly\"." >> $KCFG
> +echo >> $KCFG
> +echo -e "\t  In some cases there is low chance that kernel" >> $KCFG
> +echo -e "\t  will run different then normal, reporting or not" >> $KC=
FG
> +echo -e "\t  some bugs or errors. Refere to GCC manual for" >> $KCFG
> +echo -e "\t  more details." >> $KCFG
> +echo >> $KCFG
> +echo -e "\t  You SHOULD say N here." >> $KCFG
> +echo >> $KCFG
> +
> +for o in $OPTIMIZATIONS_PARAMS ; do
> +	cfg_o=3D"${CFG_PREFIX}_${o//-/_}";

cfg_o=3D$CFG_PREFIX_$(echo "$o" | tr '[:lower:]-' '[:upper:]_')

> +	echo "Processing param ${o} config variable will be $cfg_o";
> +
> +	# Generate kconfig entry
> +	echo -e "config ${cfg_o}" >> $KCFG
> +	echo -e "\tbool \"Adds $o parameter to gcc invoke line.\"" >> $KCFG
> +	echo -e "\t---help---" >> $KCFG
> +	echo -e "\t  This will change how GCC optimize code. Code" >> $KCFG
> +	echo -e "\t  may be slower and larger but will be more debug" >> $KC=
FG
> +	echo -e "\t  \"friendly\"." >> $KCFG
> +	echo >> $KCFG
> +	echo -e "\t  In some cases there is low chance that kernel" >> $KCFG=

> +	echo -e "\t  will run different then normal, reporting or not" >> $K=
CFG
> +	echo -e "\t  some bugs or errors. Refere to GCC manual for" >> $KCFG=

> +	echo -e "\t  more details." >> $KCFG
> +	echo >> $KCFG
> +	echo -e "\t  You SHOULD say N here." >> $KCFG
> +	echo >> $KCFG
> +
> +	#Generate Make for include
> +	echo "ifdef CONFIG_${cfg_o}" >> $MKFI
> +	echo -e "\tKBUILD_CFLAGS +=3D $o" >> $MKFI
> +	echo "endif" >> $MKFI
> +	echo  >> $MKFI
> +done;
> +echo "endif #${CFG_PREFIX}" >> $KCFG

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
