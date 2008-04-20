Received: by fg-out-1718.google.com with SMTP id e12so1153305fga.4
        for <linux-mm@kvack.org>; Sun, 20 Apr 2008 04:29:19 -0700 (PDT)
Message-ID: <480B2904.1040204@gmail.com>
Date: Sun, 20 Apr 2008 13:29:08 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: internal compiler error: SIGSEGV [Was: 2.6.25-mm1]
References: <20080418014757.52fb4a4f.akpm@linux-foundation.org>
In-Reply-To: <20080418014757.52fb4a4f.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/18/2008 10:47 AM, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.25/2.6.25-mm1/ 

Hi, I'm not sure by what was this caused.

LANG=en strace -fo strace_gcc.txt  gcc -Wp,-MD,drivers/usb/class/.usblp.o.d 
-nostdinc -isystem /usr/lib64/gcc/x86_64-suse-linux/4.3/include -D__KERNEL__ 
-Iinclude -Iinclude2 -I/home/l/latest/xxx/include -include 
include/linux/autoconf.h -I/home/l/latest/xxx/drivers/usb/class 
-Idrivers/usb/class -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs 
-fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -O2 
-fno-stack-protector -m64 -march=core2 -mno-red-zone -mcmodel=kernel 
-funit-at-a-time -maccumulate-outgoing-args -DCONFIG_AS_CFI=1 
-DCONFIG_AS_CFI_SIGNAL_FRAME=1 -pipe -Wno-sign-compare 
-fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow 
-I/home/l/latest/xxx/include/asm-x86/mach-default -Iinclude/asm-x86/mach-default 
-fno-omit-frame-pointer -fno-optimize-sibling-calls -g 
-Wdeclaration-after-statement -Wno-pointer-sign -DMODULE -D"KBUILD_STR(s)=#s" 
-D"KBUILD_BASENAME=KBUILD_STR(usblp)"  -D"KBUILD_MODNAME=KBUILD_STR(usblp)" 
/home/l/latest/xxx/drivers/usb/class/usblp.c -S -o usblp.s
/home/l/latest/xxx/drivers/usb/class/usblp.c: In function 'usblp_submit_read':
/home/l/latest/xxx/drivers/usb/class/usblp.c:977: internal compiler error: 
Segmentation fault
Please submit a full bug report,
with preprocessed source if appropriate.
See <http://bugs.opensuse.org/> for instructions.




strace_gcc.txt:
http://www.fi.muni.cz/~xslaby/sklad/strace_gcc.txt

preprocessor output available here:
http://www.fi.muni.cz/~xslaby/sklad/usblp.E

Reboot fixed it. It happened after few suspend/resume cycles. The preproc output 
differs in no way from after the reboot. Now, the strace looks like:
5341  mmap(NULL, 32768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) 
= 0x7f362e004000
5341  mmap(NULL, 1048576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 
0) = 0x7f362df04000
5341  brk(0x1964000)                    = 0x1964000
5341  brk(0x194c000)                    = 0x194c000
5341  brk(0x196d000)                    = 0x196d000
5341  brk(0x195a000)                    = 0x195a000
5341  mmap(NULL, 143360, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) 
= 0x7f362dee1000
5341  munmap(0x7f362dee1000, 143360)    = 0
5341  brk(0x1981000)                    = 0x1981000
5341  brk(0x196b000)                    = 0x196b000
5341  brk(0x1966000)                    = 0x1966000
5341  mmap(NULL, 32768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) 
= 0x7f362defc000
5341  brk(0x1988000)                    = 0x1988000

at that sigsegv place.

Some kind of random-brk gcc (gcc-4.3-30) non-readiness?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
