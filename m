Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 67B016B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:27:41 -0400 (EDT)
Received: by wwi18 with SMTP id 18so1605632wwi.2
        for <linux-mm@kvack.org>; Mon, 30 May 2011 07:27:38 -0700 (PDT)
Message-ID: <4DE3A956.5020707@simplicitymedialtd.co.uk>
Date: Mon, 30 May 2011 15:27:34 +0100
From: "Cal Leeming [Simplicity Media Ltd]" <cal.leeming@simplicitymedialtd.co.uk>
MIME-Version: 1.0
Subject: Re: cgroup OOM killer loop causes system to lockup (possible fix
 included)
References: <4DE2BFA2.3030309@simplicitymedialtd.co.uk>	<4DE2C787.1050809@simplicitymedialtd.co.uk>	<20110530112355.e92a58c0.kamezawa.hiroyu@jp.fujitsu.com>	<BANLkTikheK8O3v5HvCcKE7iiAfauDq7NhQ@mail.gmail.com> <BANLkTimzMvE7kz75umbzPFOAC5T2-vcdfQ@mail.gmail.com>
In-Reply-To: <BANLkTimzMvE7kz75umbzPFOAC5T2-vcdfQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "rientjes@google.com" <rientjes@google.com>, kamezawa.hiroyu@jp.fujitsu.com

I FOUND THE PROBLEM!!!

Explicit details can be found on the Debian kernel mailing list, but to 
cut short, it's caused by the firmware-bnx2 kernel module:

The broken server uses 'firmware-bnx2'.. so I purged the bnx2 package, 
removed the bnx*.ko files from /lib/modules, ran update-initramfs, and 
then rebooted (i then confirmed it was removed by checking ifconfig and 
lsmod).

And guess what.. IT WORKED.

So, this problem seems to be caused by the firmware-bnx2 module being 
loaded.. some how, that module is causing -17 oom_adj to be set for 
everything..

WTF?!?! Surely a bug?? Could someone please forward this to the 
appropriate person for the bnx2 kernel module, as I wouldn't even know 
where to begin :S

Cal

On 30/05/2011 11:52, Cal Leeming [Simplicity Media Ltd] wrote:
> -resent due to incorrect formatting, sorry if this dups!
>
> @Kame
> Thanks for the reply!
> Both kernels used the same env/dist, but which slightly different packages.
> After many frustrating hours, I have pin pointed this down to a dodgy
> Debian package which appears to continue affecting the system, even
> after purging. I'm still yet to pin point the package down (I'm doing
> several reinstall tests, along with tripwire analysis after each
> reboot).
>
> @Hiroyuki
> Thank you for sending this to the right people!
>
> @linux-mm
> On a side note, would someone mind taking a few minutes to give a
> brief explanation as to how the default oom_adj is set, and under what
> conditions it is given -17 by default? Is this defined by the
> application? I looked through the kernel source,
> and noticed some of the code was defaulted to set oom_adj to
> OOM_DISABLE (which is defined in the headers as -17).
>
> Assuming the debian problem is resolved, this might be another call
> for the oom-killer to be modified so that if it encounters the
> unrecoverable loop, it ignores the -17 rule (with some exceptions,
> such as kernel processes, and other critical things). If this is going
> to be a relatively simple task, I wouldn't mind spending a few hours
> patching this?
>
> Cal
>
> On Mon, May 30, 2011 at 3:23 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com>  wrote:
>> Thank you. memory cgroup and OOM troubles are handled in linux-mm.
>>
>> On Sun, 29 May 2011 23:24:07 +0100
>> "Cal Leeming [Simplicity Media Ltd]"<cal.leeming@simplicitymedialtd.co.uk>  wrote:
>>
>>> Some further logs:
>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.369927] redis-server
>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.369939]
>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.399285] redis-server
>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.399296]
>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.428690] redis-server
>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.428702]
>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.487696] redis-server
>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.487708]
>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.517023] redis-server
>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.517035]
>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.546379] redis-server
>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.546391]
>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.310789] redis-server
>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.310804]
>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.369918] redis-server
>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.369930]
>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.399284] redis-server
>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.399296]
>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.433634] redis-server
>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.433648]
>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.463947] redis-server
>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.463959]
>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.493439] redis-server
>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.493451]
>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>
>>>
>> hmm, in short, applications has -17 oom_adj in default with 2.6.32.41 ?
>> AFAIK, no kernel has such crazy settings as default..
>>
>> Does your 2 kernel uses the same environment/distribution ?
>>
>> Thanks,
>> -Kame
>>
>>> On 29/05/2011 22:50, Cal Leeming [Simplicity Media Ltd] wrote:
>>>>   First of all, my apologies if I have submitted this problem to the
>>>> wrong place, spent 20 minutes trying to figure out where it needs to
>>>> be sent, and was still none the wiser.
>>>>
>>>> The problem is related to applying memory limitations within a cgroup.
>>>> If the OOM killer kicks in, it gets stuck in a loop where it tries to
>>>> kill a process which has an oom_adj of -17. This causes an infinite
>>>> loop, which in turn locks up the system.
>>>>
>>>> May 30 03:13:08 vicky kernel: [ 1578.117055] Memory cgroup out of
>>>> memory: kill process 6016 (java) score 0 or a child
>>>> May 30 03:13:08 vicky kernel: [ 1578.117154] Memory cgroup out of
>>>> memory: kill process 6016 (java) score 0 or a child
>>>> May 30 03:13:08 vicky kernel: [ 1578.117248] Memory cgroup out of
>>>> memory: kill process 6016 (java) score 0 or a child
>>>> May 30 03:13:08 vicky kernel: [ 1578.117343] Memory cgroup out of
>>>> memory: kill process 6016 (java) score 0 or a child
>>>> May 30 03:13:08 vicky kernel: [ 1578.117441] Memory cgroup out of
>>>> memory: kill process 6016 (java) score 0 or a child
>>>>
>>>>
>>>>   root@vicky [/home/foxx]>  uname -a
>>>> Linux vicky 2.6.32.41-grsec #3 SMP Mon May 30 02:34:43 BST 2011 x86_64
>>>> GNU/Linux
>>>> (this happens on both the grsec patched and non patched 2.6.32.41 kernel)
>>>>
>>>> When this is encountered, the memory usage across the whole server is
>>>> still within limits (not even hitting swap).
>>>>
>>>> The memory configuration for the cgroup/lxc is:
>>>> lxc.cgroup.memory.limit_in_bytes = 3000M
>>>> lxc.cgroup.memory.memsw.limit_in_bytes = 3128M
>>>>
>>>> Now, what is even more strange, is that when running under the
>>>> 2.6.32.28 kernel (both patched and unpatched), this problem doesn't
>>>> happen. However, there is a slight difference between the two kernels.
>>>> The 2.6.32.28 kernel gives a default of 0 in the /proc/X/oom_adj,
>>>> where as the 2.6.32.41 gives a default of -17. I suspect this is the
>>>> root cause of why it's showing in the later kernel, but not the earlier.
>>>>
>>>> To test this theory, I started up the lxc on both servers, and then
>>>> ran a one liner which showed me all the processes with an oom_adj of -17:
>>>>
>>>> (the below is the older/working kernel)
>>>> root@courtney.internal [/mnt/encstore/lxc]>  uname -a
>>>> Linux courtney.internal 2.6.32.28-grsec #3 SMP Fri Feb 18 16:09:07 GMT
>>>> 2011 x86_64 GNU/Linux
>>>> root@courtney.internal [/mnt/encstore/lxc]>  for x in `find /proc
>>>> -iname 'oom_adj' | xargs grep "\-17"  | awk -F '/' '{print $3}'` ; do
>>>> ps -p $x --no-headers ; done
>>>> grep: /proc/1411/task/1411/oom_adj: No such file or directory
>>>> grep: /proc/1411/oom_adj: No such file or directory
>>>>    804 ?        00:00:00 udevd
>>>>    804 ?        00:00:00 udevd
>>>> 25536 ?        00:00:00 sshd
>>>> 25536 ?        00:00:00 sshd
>>>> 31861 ?        00:00:00 sshd
>>>> 31861 ?        00:00:00 sshd
>>>> 32173 ?        00:00:00 udevd
>>>> 32173 ?        00:00:00 udevd
>>>> 32174 ?        00:00:00 udevd
>>>> 32174 ?        00:00:00 udevd
>>>>
>>>> (the below is the newer/broken kernel)
>>>>   root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41]>  uname -a
>>>> Linux vicky 2.6.32.41-grsec #3 SMP Mon May 30 02:34:43 BST 2011 x86_64
>>>> GNU/Linux
>>>>   root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41]>  for x in
>>>> `find /proc -iname 'oom_adj' | xargs grep "\-17"  | awk -F '/' '{print
>>>> $3}'` ; do ps -p $x --no-headers ; done
>>>> grep: /proc/3118/task/3118/oom_adj: No such file or directory
>>>> grep: /proc/3118/oom_adj: No such file or directory
>>>>    895 ?        00:00:00 udevd
>>>>    895 ?        00:00:00 udevd
>>>>   1091 ?        00:00:00 udevd
>>>>   1091 ?        00:00:00 udevd
>>>>   1092 ?        00:00:00 udevd
>>>>   1092 ?        00:00:00 udevd
>>>>   2596 ?        00:00:00 sshd
>>>>   2596 ?        00:00:00 sshd
>>>>   2608 ?        00:00:00 sshd
>>>>   2608 ?        00:00:00 sshd
>>>>   2613 ?        00:00:00 sshd
>>>>   2613 ?        00:00:00 sshd
>>>>   2614 pts/0    00:00:00 bash
>>>>   2614 pts/0    00:00:00 bash
>>>>   2620 pts/0    00:00:00 sudo
>>>>   2620 pts/0    00:00:00 sudo
>>>>   2621 pts/0    00:00:00 su
>>>>   2621 pts/0    00:00:00 su
>>>>   2622 pts/0    00:00:00 bash
>>>>   2622 pts/0    00:00:00 bash
>>>>   2685 ?        00:00:00 lxc-start
>>>>   2685 ?        00:00:00 lxc-start
>>>>   2699 ?        00:00:00 init
>>>>   2699 ?        00:00:00 init
>>>>   2939 ?        00:00:00 rc
>>>>   2939 ?        00:00:00 rc
>>>>   2942 ?        00:00:00 startpar
>>>>   2942 ?        00:00:00 startpar
>>>>   2964 ?        00:00:00 rsyslogd
>>>>   2964 ?        00:00:00 rsyslogd
>>>>   2964 ?        00:00:00 rsyslogd
>>>>   2964 ?        00:00:00 rsyslogd
>>>>   2980 ?        00:00:00 startpar
>>>>   2980 ?        00:00:00 startpar
>>>>   2981 ?        00:00:00 ctlscript.sh
>>>>   2981 ?        00:00:00 ctlscript.sh
>>>>   3016 ?        00:00:00 cron
>>>>   3016 ?        00:00:00 cron
>>>>   3025 ?        00:00:00 mysqld_safe
>>>>   3025 ?        00:00:00 mysqld_safe
>>>>   3032 ?        00:00:00 sshd
>>>>   3032 ?        00:00:00 sshd
>>>>   3097 ?        00:00:00 mysqld.bin
>>>>   3097 ?        00:00:00 mysqld.bin
>>>>   3097 ?        00:00:00 mysqld.bin
>>>>   3097 ?        00:00:00 mysqld.bin
>>>>   3097 ?        00:00:00 mysqld.bin
>>>>   3097 ?        00:00:00 mysqld.bin
>>>>   3097 ?        00:00:00 mysqld.bin
>>>>   3097 ?        00:00:00 mysqld.bin
>>>>   3097 ?        00:00:00 mysqld.bin
>>>>   3097 ?        00:00:00 mysqld.bin
>>>>   3113 ?        00:00:00 ctl.sh
>>>>   3113 ?        00:00:00 ctl.sh
>>>>   3115 ?        00:00:00 sleep
>>>>   3115 ?        00:00:00 sleep
>>>>   3116 ?        00:00:00 .memcached.bin
>>>>   3116 ?        00:00:00 .memcached.bin
>>>>
>>>>
>>>> As you can see, it is clear that the newer kernel is setting -17 by
>>>> default, which in turn is causing the OOM killer loop.
>>>>
>>>> So I began to try and find what may have caused this problem by
>>>> comparing the two sources...
>>>>
>>>> I checked the code for all references to 'oom_adj' and 'oom_adjust' in
>>>> both code sets, but found no obvious differences:
>>>> grep -R -e oom_adjust -e oom_adj . | sort | grep -R -e oom_adjust -e
>>>> oom_adj
>>>>
>>>> Then I checked for references to "-17" in all .c and .h files, and
>>>> found a couple of matches, but only one obvious one:
>>>> grep -R "\-17" . | grep -e ".c:" -e ".h:" -e "\-17" | wc -l
>>>> ./include/linux/oom.h:#define OOM_DISABLE (-17)
>>>>
>>>> But again, a search for OOM_DISABLE came up with nothing obvious...
>>>>
>>>> In a last ditch attempt, I did a search for all references to 'oom'
>>>> (case-insensitive) in both code bases, then compared the two:
>>>>   root@annabelle [~/lol/linux-2.6.32.28]>  grep -i -R "oom" . | sort -n
>>>>> /tmp/annabelle.oom_adj
>>>>   root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41]>  grep -i -R
>>>> "oom" . | sort -n>  /tmp/vicky.oom_adj
>>>>
>>>> and this brought back (yet again) nothing obvious..
>>>>
>>>>
>>>>   root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41]>  md5sum
>>>> ./include/linux/oom.h
>>>> 2a32622f6cd38299fc2801d10a9a3ea8  ./include/linux/oom.h
>>>>
>>>>   root@annabelle [~/lol/linux-2.6.32.28]>  md5sum ./include/linux/oom.h
>>>> 2a32622f6cd38299fc2801d10a9a3ea8  ./include/linux/oom.h
>>>>
>>>>   root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41]>  md5sum
>>>> ./mm/oom_kill.c
>>>> 1ef2c2bec19868d13ec66ec22033f10a  ./mm/oom_kill.c
>>>>
>>>>   root@annabelle [~/lol/linux-2.6.32.28]>  md5sum ./mm/oom_kill.c
>>>> 1ef2c2bec19868d13ec66ec22033f10a  ./mm/oom_kill.c
>>>>
>>>>
>>>>
>>>> Could anyone please shed some light as to why the default oom_adj is
>>>> set to -17 now (and where it is actually set)? From what I can tell,
>>>> the fix for this issue will either be:
>>>>
>>>>    1. Allow OOM killer to override the decision of ignoring oom_adj ==
>>>>       -17 if an unrecoverable loop is encountered.
>>>>    2. Change the default back to 0.
>>>>
>>>> Again, my apologies if this bug report is slightly unorthodox, or
>>>> doesn't follow usual procedure etc. I can assure you I have tried my
>>>> absolute best to give all the necessary information though.
>>>>
>>>> Cal
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
