Message-ID: <47D29CAB.50301@tuxrocks.com>
Date: Sat, 08 Mar 2008 08:03:23 -0600
From: Frank Sorenson <frank@tuxrocks.com>
MIME-Version: 1.0
Subject: Re: 2.6.25-rc4 OOMs itself dead on bootup (modprobe bug?)
References: <47D02940.1030707@tuxrocks.com> <20080306184954.GA15492@elte.hu> <47D1971A.7070500@tuxrocks.com> <47D23B7E.3020505@tuxrocks.com> <20080308135318.GA8036@auslistsprd01.us.dell.com>
In-Reply-To: <20080308135318.GA8036@auslistsprd01.us.dell.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Domsch <Matt_Domsch@dell.com>
Cc: Ingo Molnar <mingo@elte.hu>, kay.sievers@vrfy.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, jcm@redhat.com
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Matt Domsch wrote:
> On Sat, Mar 08, 2008 at 01:08:46AM -0600, Frank Sorenson wrote:
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA1
>>
>> Frank Sorenson wrote:
>>> I did some additional debugging, and I believe you're correct about it
>>> being specific to my system.  The system seems to run fine until some
>>> time during the boot.  I booted with "init=/bin/sh" (that's how the
>>> system stayed up for 9 minutes), then it died when I tried starting
>>> things up.  I've further narrowed the OOM down to udev (though it's not
>>> entirely udev's fault, since 2.6.24 runs fine).
>>>
>>> I ran your debug info tool before killing the box by running
>>> /sbin/start_udev.  The output of the tool is at
>>> http://tuxrocks.com/tmp/cfs-debug-info-2008.03.06-14.11.24
>>>
>>> Something is apparently happening between 2.6.24 and 2.6.25-rc[34] which
>>> causes udev (or something it calls) to behave very badly.
>> Found it.  The culprit is 8f47f0b688bba7642dac4e979896e4692177670b
>>     dcdbas: add DMI-based module autloading
>>
>>     DMI autoload dcdbas on all Dell systems.
>>
>>     This looks for BIOS Vendor or System Vendor == Dell, so this should
>>     work for systems both Dell-branded and those Dell builds but brands
>>     for others.  It causes udev to load the dcdbas module at startup,
>>     which is used by tools called by HAL for wireless control and
>>     backlight control, among other uses.
>>
>> What actually happens is that when udev loads the dcdbas module at
>> startup, modprobe apparently calls "modprobe dcdbas" itself, repeating
>> until the system runs out of resources (in this case, it OOMs).
>>
>> # ps axf
>> ...
>>   506 ?        S      0:00 /bin/bash /sbin/start_udev
>>   590 ?        S      0:00  \_ /sbin/udevsettle
>>   533 ?        S<s    0:00 /sbin/udevd -d
>>   629 ?        S<     0:00  \_ /sbin/udevd -d
>>   630 ?        S<     0:00  |   \_ /sbin/modprobe
>> dmi:bvnDellInc.:bvrA08:bd04/02/2007:svnDellInc.:pnMP061:pvr:rvnDellInc.:rn0YD479:rvr:cvnDellInc.:ct8:cvr:
>>   949 ?        S<     0:00  |       \_ /sbin/modprobe dcdbas
>>   950 ?        S<     0:00  |           \_ /sbin/modprobe dcdbas
>>   951 ?        S<     0:00  |               \_ /sbin/modprobe dcdbas
>>   953 ?        S<     0:00  |                   \_ /sbin/modprobe dcdbas
>>   955 ?        S<     0:00  |                       \_ /sbin/modprobe dcdbas
>>   958 ?        S<     0:00  |                           \_
>> /sbin/modprobe dcdbas
>> ...repeat...
>>
>> When the system crashed, there were at least 11,600 instances of
>> "/sbin/modprobe dcdbas", each calling the next.
>>
>> Reverting 8f47f0b lets the system boot up just fine again.  Note that a
>> manual "modprobe dcdbas" also causes this recursive behavior, it's just
>> not forced on the system by udev.
>>
>> So dcdbas is a regression from 2.6.24, as well as being broken in other
>> ways.
>>
>> Frank
>> - --
>> Frank Sorenson - KD7TZK
>> Linux Systems Engineer, DSS Engineering, UBS AG
>> frank@tuxrocks.com
> 
> 
> Frank, what version of module-init-tools do you have?  This has been
> in use in Fedora 8 for a few months, and this is the first failure
> report I've seen.
> 
> I'm fine with reverting the patch for now, but really do want to get
> to root cause, because module autoloading is a really good idea, and
> it would be a shame if we couldn't keep that feature enabled because
> some systems have incompatible module-init-tools, and the kernel can't
> know that...  (Perhaps udev could know and not invoke modprobe in
> those instances?)
> 
> -Matt

It's module-init-tools-3.4-2.fc8.x86_64 (most recent Fedora rpm available).

Frank
- --
Frank Sorenson - KD7TZK
Linux Systems Engineer, DSS Engineering, UBS AG
frank@tuxrocks.com
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFH0pyoaI0dwg4A47wRAq9rAKCVbg5ngSyHVORpLAcD4WY4vNMQlQCdGtr1
9CiHmom5Vopsqukc8e+D1RU=
=GPMU
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
