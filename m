Message-ID: <47D1971A.7070500@tuxrocks.com>
Date: Fri, 07 Mar 2008 13:27:22 -0600
From: Frank Sorenson <frank@tuxrocks.com>
MIME-Version: 1.0
Subject: Re: 2.6.25-rc4 OOMs itself dead on bootup
References: <47D02940.1030707@tuxrocks.com> <20080306184954.GA15492@elte.hu>
In-Reply-To: <20080306184954.GA15492@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Ingo Molnar wrote:
> * Frank Sorenson <frank@tuxrocks.com> wrote:
> 
>> 2.6.25-rc4 invokes the oom-killer repeatedly when attempting to boot, 
>> eventually panicing with "Out of memory and no killable processes." 
>> This happens since at least 2.6.25-rc3, but 2.6.24 boots just fine,
>>
>> The system is a Dell Inspiron E1705 running Fedora 8 (x86_64).
>>
>> My .config is at http://tuxrocks.com/tmp/config-2.6.25-rc4, and a 
>> syslog of the system up until the point where it oom-killed syslog 
>> (just before the panic) is at 
>> http://tuxrocks.com/tmp/oom-2.6.25-rc4.txt
> 
> i've picked up your .config and enabled a few drivers in it to make it 
> boot on a testsystem of mine and it doesnt OOM:
> 
>  20:47:17 up 10 min,  1 user,  load average: 0.01, 0.07, 0.03
>               total       used       free     shared    buffers     cached
>  Mem:       1025768     258544     767224          0      12956     169556
>  -/+ buffers/cache:      76032     949736
>  Swap:      3911816          0    3911816
> 
> (config and bootlog from my box attached.)
> 
> So it's probably not a .config dependent generic kernel problem, but 
> probably something specific to your hardware.
> 
> Since the first oom happens about 9 minutes into the bootup:
> 
>  [  569.755853] sh invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=-17
> 
> do you have any chance to log in and capture MM statistics? The 
> following script will capture a bunch of statistics:
> 
>  http://people.redhat.com/mingo/cfs-scheduler/tools/cfs-debug-info.sh
> 
> and takes less than a minute to run - should be enough time in theory. 
> If it's possible to run it then send us the output file it produces.
> 
> 	Ingo

Thank you for the help, and for the time.

I did some additional debugging, and I believe you're correct about it
being specific to my system.  The system seems to run fine until some
time during the boot.  I booted with "init=/bin/sh" (that's how the
system stayed up for 9 minutes), then it died when I tried starting
things up.  I've further narrowed the OOM down to udev (though it's not
entirely udev's fault, since 2.6.24 runs fine).

I ran your debug info tool before killing the box by running
/sbin/start_udev.  The output of the tool is at
http://tuxrocks.com/tmp/cfs-debug-info-2008.03.06-14.11.24

Something is apparently happening between 2.6.24 and 2.6.25-rc[34] which
causes udev (or something it calls) to behave very badly.

I'll keep looking further into the cause.  Thanks again for the help.

Frank
- --
Frank Sorenson - KD7TZK
Linux Systems Engineer, DSS Engineering, UBS AG
frank@tuxrocks.com
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFH0ZcXaI0dwg4A47wRAoy7AJ9ILIlACjitvOpNghRNxmOgiygk1QCfb3Oi
8Drhxc4Tvu0K+1KD0U6XUOE=
=SmQj
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
