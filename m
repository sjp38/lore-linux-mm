Subject: Re: 2.5.33-mm3 dbench hang and 2.5.33 page allocation failures
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <3D77B28F.488933FB@zip.com.au>
References: <1031250156.2799.86.camel@spc9.esa.lanl.gov>
	<1031253714.1990.116.camel@spc9.esa.lanl.gov>
	<3D77B28F.488933FB@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 06 Sep 2002 08:14:55 -0600
Message-Id: <1031321695.1984.132.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-09-05 at 13:37, Andrew Morton wrote:

> 
> grr.  I run dbench all night, so any insight you can get into this
> would be appreciated.  (I've had a few hangs, but they're due
> to bust disk drivers, aic7xxx not handling IO errors correctly, etc)

Double grr.  I just ran 2.5.33-mm4 and got the hang at dbench 8.  And in
my haste, I forgot to enable sysrq after boot.
> 
> > BTW, the note in Documentation/sysrq.txt about not needing to enable
> > /proc/sys/kernel/sysrq anymore appears to be incorrect.  I had to set
> > this to 1 as it was set to 0 on boot.
> 
> grep your initscripts.  Some distros turn it off by hand.

[root@spc5 steven]# find /etc -name "*" | xargs grep sysrq
/etc/sysctl.conf:kernel.sysrq = 0

This is from RH 7.3.  Fixed.  Thanks.

For what it's worth, I ran the output from sysrq-p (2.5.33-mm3
yesterday) through ksymoops, and here is the result. I typed those
numbers in manually. I'll try to get time to set up a serial console
today.

Steven

[steven@spc5 linux-2.5.33-mm3]$ ksymoops -K -L -O -v vmlinux -m System.map <regdump.txt
ksymoops 2.4.4 on i686 2.4.18-3smp.  Options used
     -v vmlinux (specified)
     -K (specified)
     -L (specified)
     -O (specified)
     -m System.map (specified)

Pid: 1219, comm:        pdflush
EIP: 0060:[<c015a388>] CPU:1 EFLASHS: 00000202  Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EAX: eaf09f88 EBX: 00000000 ECX: 00000020 edx: 00000400
ESI: eaf09f88 EDI: 000065c2 EBP: eaf09fd0 DS: 0068 es: 0068
CR0: 8005003b CR2: 40262000 CR3: 1e5b5000 CR4: 00000690
Call Trace: [<c013bb1a>] [<c013b73b>] [<c013b7e0>] [<c013b7eb>] [<c013baa0>]
[<c01072284>] [<c0107289>]
Warning (Oops_read): Code line not seen, dumping what data is available

>>EIP; c015a388 <.text.lock.fs_writeback+47/cf>   <=====
Trace; c013bb1a <background_writeout+7a/c0>
Trace; c013b73b <__pdflush+12b/1d0>
Trace; c013b7e0 <pdflush+0/10>
Trace; c013b7eb <pdflush+b/10>
Trace; c013baa0 <background_writeout+0/c0>
Trace; 0000000c01072284 <END_OF_CODE+b40ce7870/????>
Trace; c0107289 <kernel_thread_helper+5/c>


1 warning issued.  Results may not be reliable.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
