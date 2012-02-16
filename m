Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id CAE366B0092
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 15:26:01 -0500 (EST)
Subject: Re: [PATCH 01/18] Added hacking menu for override optimization by  GCC.
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Date: Thu, 16 Feb 2012 21:26:00 +0100
From: =?UTF-8?Q?Rados=C5=82aw_Smogura?= <mail@smogura.eu>
In-Reply-To: <op.v9sctsrj3l0zgt@mpn-glaptop>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
 <op.v9sctsrj3l0zgt@mpn-glaptop>
Message-ID: <76ede790fcc4ab73f969761034554e92@rsmogura.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: linux-mm@kvack.org, Yongqiang Yang <xiaoqiangnk@gmail.com>, linux-ext4@vger.kernel.org

On Thu, 16 Feb 2012 11:09:18 -0800, Michal Nazarewicz wrote:
> On Thu, 16 Feb 2012 06:31:28 -0800, RadosA?aw Smogura 
> <mail@smogura.eu> wrote:
>> Supporting files, like Kconfig, Makefile are auto-generated due to 
>> large amount
>> of available options.
>
> So why not run the script as part of make rather then store generated
> files in
> repository?
Idea to run this script through make is quite good, and should work, 
because new mane will be generated before "config" starts.

"Bashizms" are indeed unneeded, I will try to replace this with sed.

>> diff --git a/scripts/debug/make_config_optim.sh 
>> b/scripts/debug/make_config_optim.sh
>> new file mode 100644
>> index 0000000..26865923
>> --- /dev/null
>> +++ b/scripts/debug/make_config_optim.sh
>> @@ -0,0 +1,88 @@
>> +#!/bin/sh
>
> The below won't run on POSIX-compatible sh.  Address my comments
> below to fix that.
>
>> +
>> +## Utility script for generating optimization override options
>> +## for kernel compilation.
>> +##
>> +## Distributed under GPL v2 license
>> +## (c) RadosA?aw Smogura, 2011
>> +
>> +# Prefix added for variable
>> +CFG_PREFIX="HACK_OPTIM"
>> +
>> +KCFG="Kconfig.debug.optim"
>> +MKFI="Makefile.optim.inc"
>
> How about names that mean something?
>
> KCONFIG=...
> MAKEFILE=...
>
>> +
>> +OPTIMIZATIONS_PARAMS="-fno-inline-functions-called-once \
>> + -fno-combine-stack-adjustments \
>> + -fno-tree-dce \
>> + -fno-tree-dominator-opts \
>> + -fno-dse "
>
> Slashes at end of lines are not necessary here.
>
>> +
>> +echo "# This file was auto generated. It's utility configuration" > 
>> $KCFG
>> +echo "# Distributed under GPL v2 License" >> $KCFG
>> +echo >> $KCFG
>> +echo "menuconfig ${CFG_PREFIX}" >> $KCFG
>> +echo -e "\tbool \"Allows to override GCC optimization\"" >> $KCFG
>> +echo -e "\tdepends on DEBUG_KERNEL && EXPERIMENTAL" >> $KCFG
>> +echo -e "\thelp" >> $KCFG
>> +echo -e "\t  If you say Y here you will be able to override" >> 
>> $KCFG
>> +echo -e "\t  how GCC optimize kernel code. This will create" >> 
>> $KCFG
>> +echo -e "\t  more debug friendly, but with not guarentee"    >> 
>> $KCFG
>> +echo -e "\t  about same runi, like production, kernel."      >> 
>> $KCFG
>> +echo >> $KCFG
>> +echo -e "\t  If you say Y here probably You will want say"   >> 
>> $KCFG
>> +echo -e "\t  for all suboptions" >> $KCFG
>> +echo >> $KCFG
>> +echo "if ${CFG_PREFIX}" >> $KCFG
>> +echo >> $KCFG
>
> Use:
>
> cat > $KCFG <<EOF
> ...
> EOF
>
> through the file (of course, in next runs you'll need to use a??>> 
> $KCFGa??).
> More readable and also a??-ea?? argument to echo is bash-specific.
>
> Alternatively to using a??> $KCFGa?? all the time, you can also do:
>
> exec 3> Kconfig.debug.optim
> exec 4> Makefile.optim.inc
>
> at the beginning of the script and later use >&3 and >&4, which will 
> save
> you some open/close calls and make the strangely named $KCFG and 
> $MKFI
> variables no longer needed.
>
>> +
>> +echo "# This file was auto generated. It's utility configuration" > 
>> $MKFI
>> +echo "# Distributed under GPL v2 License" >> $MKFI
>> +echo >> $MKFI
>> +
>> +# Insert standard override optimization level
>> +# This is exception, and this value will not be included
>> +# in auto generated makefile. Support for this value
>> +# is hard coded in main Makefile.
>> +echo -e "config ${CFG_PREFIX}_FORCE_O1_LEVEL" >> $KCFG
>> +echo -e "\tbool \"Forces -O1 optimization level\"" >> $KCFG
>> +echo -e "\t---help---" >> $KCFG
>> +echo -e "\t  This will change how GCC optimize code. Code" >> $KCFG
>> +echo -e "\t  may be slower and larger but will be more debug" >> 
>> $KCFG
>> +echo -e "\t  \"friendly\"." >> $KCFG
>> +echo >> $KCFG
>> +echo -e "\t  In some cases there is low chance that kernel" >> 
>> $KCFG
>> +echo -e "\t  will run different then normal, reporting or not" >> 
>> $KCFG
>> +echo -e "\t  some bugs or errors. Refere to GCC manual for" >> 
>> $KCFG
>> +echo -e "\t  more details." >> $KCFG
>> +echo >> $KCFG
>> +echo -e "\t  You SHOULD say N here." >> $KCFG
>> +echo >> $KCFG
>> +
>> +for o in $OPTIMIZATIONS_PARAMS ; do
>> +	cfg_o="${CFG_PREFIX}_${o//-/_}";
>
> cfg_o=$CFG_PREFIX_$(echo "$o" | tr '[:lower:]-' '[:upper:]_')
>
>> +	echo "Processing param ${o} config variable will be $cfg_o";
>> +
>> +	# Generate kconfig entry
>> +	echo -e "config ${cfg_o}" >> $KCFG
>> +	echo -e "\tbool \"Adds $o parameter to gcc invoke line.\"" >> 
>> $KCFG
>> +	echo -e "\t---help---" >> $KCFG
>> +	echo -e "\t  This will change how GCC optimize code. Code" >> 
>> $KCFG
>> +	echo -e "\t  may be slower and larger but will be more debug" >> 
>> $KCFG
>> +	echo -e "\t  \"friendly\"." >> $KCFG
>> +	echo >> $KCFG
>> +	echo -e "\t  In some cases there is low chance that kernel" >> 
>> $KCFG
>> +	echo -e "\t  will run different then normal, reporting or not" >> 
>> $KCFG
>> +	echo -e "\t  some bugs or errors. Refere to GCC manual for" >> 
>> $KCFG
>> +	echo -e "\t  more details." >> $KCFG
>> +	echo >> $KCFG
>> +	echo -e "\t  You SHOULD say N here." >> $KCFG
>> +	echo >> $KCFG
>> +
>> +	#Generate Make for include
>> +	echo "ifdef CONFIG_${cfg_o}" >> $MKFI
>> +	echo -e "\tKBUILD_CFLAGS += $o" >> $MKFI
>> +	echo "endif" >> $MKFI
>> +	echo  >> $MKFI
>> +done;
>> +echo "endif #${CFG_PREFIX}" >> $KCFG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
