Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3B956B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 02:59:55 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 79so70464928pgf.2
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 23:59:55 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0108.outbound.protection.outlook.com. [104.47.0.108])
        by mx.google.com with ESMTPS id w30si4244381pgc.219.2017.03.30.23.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 23:59:54 -0700 (PDT)
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
 <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
 <20170330194143.cbracica3w3ijrcx@codemonkey.org.uk>
 <CAGXu5jK8=g8rBx1J4+gC8-3nwRLe2Va89hHX=S-P6SvvgiVb9A@mail.gmail.com>
 <20170330200100.zcyndf3kimepg77o@codemonkey.org.uk>
 <81379c63-674c-a37f-a6f6-5af385138a25@nokia.com>
From: Tommi Rantala <tommi.t.rantala@nokia.com>
Message-ID: <599c2a8b-81d2-654e-4147-dfe9e5b98fc2@nokia.com>
Date: Fri, 31 Mar 2017 09:59:44 +0300
MIME-Version: 1.0
In-Reply-To: <81379c63-674c-a37f-a6f6-5af385138a25@nokia.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>, Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>

On 31.03.2017 08:40, Tommi Rantala wrote:
>> The only thing that I can think of would be a rogue ptr in the bios
>> table, but that seems unlikely.  Tommi, can you put strace of x86info
>> -mp somewhere?
>> That will confirm/deny whether we're at least asking the kernel to do
>> sane things.
>
> Indeed the bug happens when reading from /dev/mem:
>
> https://pastebin.com/raw/ZEJGQP1X
>
> # strace -f -y x86info -mp
> [...]
> open("/dev/mem", O_RDONLY)              = 3</dev/mem>
> lseek(3</dev/mem>, 1038, SEEK_SET)      = 1038
> read(3</dev/mem>, "\300\235", 2)        = 2
> lseek(3</dev/mem>, 646144, SEEK_SET)    = 646144
> read(3</dev/mem>,
> "\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
> 1024) = 1024
> lseek(3</dev/mem>, 1043, SEEK_SET)      = 1043
> read(3</dev/mem>, "w\2", 2)             = 2
> lseek(3</dev/mem>, 645120, SEEK_SET)    = 645120
> read(3</dev/mem>,
> "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
> 1024) = 1024
> lseek(3</dev/mem>, 654336, SEEK_SET)    = 654336
> read(3</dev/mem>,
> "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
> 1024) = 1024
> lseek(3</dev/mem>, 983040, SEEK_SET)    = 983040
> read(3</dev/mem>,
> "IFE$\245S\0\0\1\0\0\0\0\360y\0\0\360\220\260\30\237{=\23\10\17\0000\276\17\0"...,
> 65536) = 65536
> lseek(3</dev/mem>, 917504, SEEK_SET)    = 917504
> read(3</dev/mem>,
> "\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377"...,
> 65536) = 65536
> lseek(3</dev/mem>, 524288, SEEK_SET)    = 524288
> read(3</dev/mem>,  <unfinished ...>)    = ?
> +++ killed by SIGSEGV +++

That last read is done in mptable.c:347, trying to read GROPE_AREA1.

# ./x86info --debug
x86info v1.31pre
get_intel_topology:
         Siblings: 2
         Physical Processor ID: 0
         Processor Core ID: 0
get_intel_topology:
         Siblings: 2
         Physical Processor ID: 0
         Processor Core ID: 1
get_intel_topology:
         Siblings: 2
         Physical Processor ID: 0
         Processor Core ID: 2
get_intel_topology:
         Siblings: 2
         Physical Processor ID: 0
         Processor Core ID: 3
get_intel_topology:
         Siblings: 2
         Physical Processor ID: 0
         Processor Core ID: 0
get_intel_topology:
         Siblings: 2
         Physical Processor ID: 0
         Processor Core ID: 1
get_intel_topology:
         Siblings: 2
         Physical Processor ID: 0
         Processor Core ID: 2
get_intel_topology:
         Siblings: 2
         Physical Processor ID: 0
         Processor Core ID: 3
Found 8 identical CPUs
EBDA points to: 9dc0
EBDA segment ptr: 9dc00
Segmentation fault


If I comment out the GROPE_AREA1 read, the same kernel bug still happens 
with the GROPE_AREA2 read.

Removing both GROPE_AREA1 and GROPE_AREA2 reads avoids the crash:

$ git diff
diff --git a/mptable.c b/mptable.c
index 480f19b..00fff35 100644
--- a/mptable.c
+++ b/mptable.c
@@ -342,6 +342,7 @@ static int apic_probe(unsigned long* paddr)
         }

         /* search additional memory */
+       /*
         target = GROPE_AREA1;
         seekEntry(target);
         if (readEntry(buffer, GROPE_SIZE)) {
@@ -371,6 +372,7 @@ static int apic_probe(unsigned long* paddr)
                         return 6;
                 }
         }
+       */

         *paddr = (unsigned long)0;
         return 0;

# ./x86info -mp
x86info v1.31pre
Found 8 identical CPUs
Extended Family: 0 Extended Model: 5 Family: 6 Model: 94 Stepping: 3
Type: 0 (Original OEM)
CPU Model (x86info's best guess): Unknown model.
Processor name string (BIOS programmed): Intel(R) Core(TM) i7-6820HQ CPU 
@ 2.70GHz

Total processor threads: 8
This system has 1 quad-core processor with hyper-threading (2 threads 
per core) running at an estimated 2.70GHz
#

-Tommi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
