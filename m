Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0AC6B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 15:29:25 -0400 (EDT)
Received: by wwi36 with SMTP id 36so4411489wwi.26
        for <linux-mm@kvack.org>; Tue, 31 May 2011 12:29:20 -0700 (PDT)
Message-ID: <4DE54187.5060208@simplicitymedialtd.co.uk>
Date: Tue, 31 May 2011 20:29:11 +0100
From: "Cal Leeming [Simplicity Media Ltd]" <cal.leeming@simplicitymedialtd.co.uk>
MIME-Version: 1.0
Subject: Re: cgroup OOM killer loop causes system to lockup (possible fix
 included)
References: <4DE2BFA2.3030309@simplicitymedialtd.co.uk>	<4DE2C787.1050809@simplicitymedialtd.co.uk>	<20110530112355.e92a58c0.kamezawa.hiroyu@jp.fujitsu.com>	<BANLkTikheK8O3v5HvCcKE7iiAfauDq7NhQ@mail.gmail.com> <BANLkTimzMvE7kz75umbzPFOAC5T2-vcdfQ@mail.gmail.com> <4DE3A956.5020707@simplicitymedialtd.co.uk> <4DE3D5A8.8060707@simplicitymedialtd.co.uk> <4DE40DCA.3000909@simplicitymedialtd.co.uk>
In-Reply-To: <4DE40DCA.3000909@simplicitymedialtd.co.uk>
Content-Type: multipart/alternative;
 boundary="------------040802070209080002020205"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gert Doering <gert@greenie.muc.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "rientjes@google.com" <rientjes@google.com>, kamezawa.hiroyu@jp.fujitsu.com

This is a multi-part message in MIME format.
--------------040802070209080002020205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This is now being handed back to linux-mm for re-assessment.. OpenSSH 
devs are saying this is not a fault in their code..

It would appear that the loadable bnx2 module is causing strange oom_adj 
behavior.. and if its affecting this, I wonder what else it might be 
affecting? Bug can only be reproduced when the module is in use by 
actual hardware.

Here is the latest conversation with openssh devs, which confirms this 
definitely falls within the remit of debian or kernel-mm.

On 31/05/2011 13:25, Gert Doering wrote:
 > Hi,
 >
 > On Tue, May 31, 2011 at 12:11:13PM +0100, Cal Leeming [Simplicity 
Media Ltd] wrote:
 >> Could you point out the line of code where oom_adj_save is set to the
 >> original value, because I've looked everywhere, and from what I can
 >> tell, it's only ever set to INT_MIN, and no where else is it changed.
 >> (C is not my strongest language tho, so I most likely have overlooked
 >> something). This is where I got thrown off.
 >
 > oom_adjust_setup() does this:
 >
 >                 if ((fp = fopen(oom_adj_path, "r+")) != NULL) {
 >                         if (fscanf(fp, "%d", &oom_adj_save) != 1)
 >                                 verbose("error reading %s: %s", 
oom_adj_path,
 >                                     strerror(errno));
 >
 > the "fscanf()" call will read an integer ("%d") from the file named,
 > and write that number into the variable being pointed to 
(&oom_adj_save).
 >
 > The loop is a bit tricky to read as it takes different paths into
 > account, and will exit after the first successful update.
 >
 > fscanf() will return the number of successful conversions, so if it
 > was able to read "one number", the return value is "1", and it will
 > jump to the else block
 >
 >                         else {
 >                                 rewind(fp);
 >                                 if (fprintf(fp, "%d\n", value) <= 0)
 >                                         verbose("error writing %s: %s",
 >                                            oom_adj_path, 
strerror(errno));
 >                                 else
 >                                         verbose("Set %s from %d to %d",
 >                                            oom_adj_path, 
oom_adj_save, value);
 >                         }
 >
 > where it will overwrite what is in that file with the new value
 > ("value"), and then print the "Set ... from -17 to -17" message that
 > you saw.

Ah, thank you for explaining this. Makes a lot more sense now :)

 >
 >
 >>> The question here is why sshd is sometimes started with -17 and 
sometimes
 >>> with 0 - that's the bug, not that sshd keeps what it's given.
 >>>
 >>> (Ask yourself: if sshd had no idea about oom_adj at all, would this 
make
 >>> it buggy by not changing the value?)
 >>
 >> This was what I was trying to pinpoint down before. I had came to this
 >> conclusion myself, sent it to the Debian bug list, and they dismissed
 >> on the grounds that it was an openssh problem...
 >
 > I must admit that I have no idea what is causing it, but from the logs,
 > it very much looks like sshd is started with "-17" in there - but only
 > in the problem case.
 >
 >
 >> So far, the buck has been passed from kernel-mm to debian-kernel, to
 >> openssh, and now back to debian-kernel lol. The most annoying thing,
 >> is that you can't get this bug to happen unless you physically test on
 >> a machine which requires the bnx2 firmwire, so I get the feeling this
 >> won't get resolved :/
 >
 > And *that* strongly points to a bug in the bnx2 stuff - if other 
programs
 > change their behaviour based on the existance of a given driver, that
 > does not smell very healthy.

Agreed.. I was thinking of adding some debug into the fs/proc/ code 
which does a kprint on every oom_adj read/write, but I couldn't figure 
out how to extract the pid from the task (pointer?).

 >
 > [..]
 >>> Anyway, as a workaround for your system, you can certainly set
 >>>
 >>>  oom_adj_save = 0;
 >>>
 >>> in the beginning of port-linux.c / oom_adjust_restore(), to claim that
 >>> "hey, this was the saved value to start with" and "restore" oom_adj 
to 0
 >>> then - but that's just hiding the bug, not fixing it.
 >>
 >> I'm disappointed this wasn't the correct fix, I honestly thought I had
 >> patched it right :(
 >
 > Well, that's the short hand - "just ignore everything that happened at
 > init / save time, and forcibly write back '0', no matter what was there
 > before".
 >
 >> But, on the other hand, ssh users should really never have a default
 >> oom_adj of -17, so maybe 0 should be set as default anyway? If this is
 >> not the case, could you give reasons why??
 >
 > Well, I would say "the default value in there is a matter of local 
policy",
 > so what if someone wants to make sure that whatever is run from sshd is
 > always privileged regarding oom, even if a local firefox etc. is running
 > amock and you need to ssh-in and kill the GUI stuff...
 >
 > One might opt to run sshd (and all its children) at "-5" (slightly 
special
 > treatment), or "0" (no special treatment), or even at "-17" - but that's
 > local policy.

Ah, okay that's make sense.

 >
 >
 > Mmmh.
 >
 > Since this seems to be inherited, it might even work if you just change
 > the sshd startup script, and insert
 >
 >   echo 0 >/proc/self/oom_adj
 >
 > in there, right before it starts the sshd...  "local policy at work".

Yeah I was going to do this, but then I thought "well if this problem is 
occurring for openssh, then what else could it be affecting?". As you 
pointed out above, having the oom_adj changed based on the existence of 
a driver is really not good.

I will paste this convo trail into the debian ticket, and hopefully 
it'll help convince them this issue needs fixing.

 >
 > gert

Thanks again for taking the time to reply!



On 30/05/2011 22:36, Cal Leeming [Simplicity Media Ltd] wrote:
> FYI everyone, I found a bug within openssh-server which caused this 
> problem.
>
> I've patched and submitted to the openssh list.
>
> You can find details of this by googling for:
> "port-linux.c bug with oom_adjust_restore() - causes real bad oom_adj 
> - which can cause DoS conditions"
>
> It's extremely strange.. :S
>
> Cal
>
> On 30/05/2011 18:36, Cal Leeming [Simplicity Media Ltd] wrote:
>> Here is an strace of the SSH process (which is somehow inheriting the 
>> -17 oom_adj on all forked user instances)
>>
>> (broken server - with bnx2 module loaded)
>> [pid  2200] [    7f13a09c9cb0] open("/proc/self/oom_adj", 
>> O_WRONLY|O_CREAT|O_TRUNC, 0666 <unfinished ...>
>> [pid  2120] [    7f13a09c9f00] write(7, "\0\0\2\240\n\n\n\nPort 
>> 22\n\n\n\nProtocol 2\n\nH"..., 680 <unfinished ...>
>> [pid  2200] [    7f13a09c9cb0] <... open resumed> ) = 9
>> [pid  2120] [    7f13a09c9f00] <... write resumed> ) = 680
>> [pid  2120] [    7f13a09c9e40] close(7 <unfinished ...>
>> [pid  2200] [    7f13a09c9844] fstat(9, <unfinished ...>
>> [pid  2120] [    7f13a09c9e40] <... close resumed> ) = 0
>> [pid  2200] [    7f13a09c9844] <... fstat resumed> 
>> {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
>> [pid  2120] [    7f13a09c9e40] close(8 <unfinished ...>
>> [pid  2200] [    7f13a09d2a2a] mmap(NULL, 4096, PROT_READ|PROT_WRITE, 
>> MAP_PRIVATE|MAP_ANONYMOUS, -1, 0 <unfinished ...>
>> [pid  2120] [    7f13a09c9e40] <... close resumed> ) = 0
>> [pid  2200] [    7f13a09d2a2a] <... mmap resumed> ) = 0x7f13a25a6000
>> [pid  2120] [    7f13a09c9e40] close(4 <unfinished ...>
>> [pid  2200] [    7f13a09c9f00] write(9, "-17\n", 4 <unfinished ...>
>>
>>
>> (working server - with bnx2 module unloaded)
>> [pid  1323] [    7fae577fbe40] close(7) = 0
>> [pid  1631] [    7fae577fbcb0] open("/proc/self/oom_adj", 
>> O_WRONLY|O_CREAT|O_TRUNC, 0666 <unfinished ...>
>> [pid  1323] [    7fae577fbf00] write(8, "\0\0\2\217\0", 5 <unfinished 
>> ...>
>> [pid  1631] [    7fae577fbcb0] <... open resumed> ) = 10
>> [pid  1323] [    7fae577fbf00] <... write resumed> ) = 5
>> [pid  1323] [    7fae577fbf00] write(8, "\0\0\2\206\n\n\n\nPort 
>> 22\n\n\n\nProtocol 2\n\nH"..., 654 <unfinished ...>
>> [pid  1631] [    7fae577fb844] fstat(10, <unfinished ...>
>> [pid  1323] [    7fae577fbf00] <... write resumed> ) = 654
>> [pid  1631] [    7fae577fb844] <... fstat resumed> 
>> {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
>> [pid  1323] [    7fae577fbe40] close(8) = 0
>> [pid  1631] [    7fae57804a2a] mmap(NULL, 4096, PROT_READ|PROT_WRITE, 
>> MAP_PRIVATE|MAP_ANONYMOUS, -1, 0 <unfinished ...>
>> [pid  1323] [    7fae577fbe40] close(9 <unfinished ...>
>> [pid  1631] [    7fae57804a2a] <... mmap resumed> ) = 0x7fae593d9000
>> [pid  1323] [    7fae577fbe40] <... close resumed> ) = 0
>> [pid  1323] [    7fae577fbe40] close(5 <unfinished ...>
>> [pid  1631] [    7fae577fbf00] write(10, "0\n", 2 <unfinished ...>
>>
>> The two servers are *EXACT* duplicates of each other, completely 
>> fresh Debian installs, with exactly the same packages installed.
>>
>> As you can see, the working server sends "0" into the oom_adj and the 
>> broken one sends "-17".
>>
>>
>> On 30/05/2011 15:27, Cal Leeming [Simplicity Media Ltd] wrote:
>>> I FOUND THE PROBLEM!!!
>>>
>>> Explicit details can be found on the Debian kernel mailing list, but 
>>> to cut short, it's caused by the firmware-bnx2 kernel module:
>>>
>>> The broken server uses 'firmware-bnx2'.. so I purged the bnx2 
>>> package, removed the bnx*.ko files from /lib/modules, ran 
>>> update-initramfs, and then rebooted (i then confirmed it was removed 
>>> by checking ifconfig and lsmod).
>>>
>>> And guess what.. IT WORKED.
>>>
>>> So, this problem seems to be caused by the firmware-bnx2 module 
>>> being loaded.. some how, that module is causing -17 oom_adj to be 
>>> set for everything..
>>>
>>> WTF?!?! Surely a bug?? Could someone please forward this to the 
>>> appropriate person for the bnx2 kernel module, as I wouldn't even 
>>> know where to begin :S
>>>
>>> Cal
>>>
>>> On 30/05/2011 11:52, Cal Leeming [Simplicity Media Ltd] wrote:
>>>> -resent due to incorrect formatting, sorry if this dups!
>>>>
>>>> @Kame
>>>> Thanks for the reply!
>>>> Both kernels used the same env/dist, but which slightly different 
>>>> packages.
>>>> After many frustrating hours, I have pin pointed this down to a dodgy
>>>> Debian package which appears to continue affecting the system, even
>>>> after purging. I'm still yet to pin point the package down (I'm doing
>>>> several reinstall tests, along with tripwire analysis after each
>>>> reboot).
>>>>
>>>> @Hiroyuki
>>>> Thank you for sending this to the right people!
>>>>
>>>> @linux-mm
>>>> On a side note, would someone mind taking a few minutes to give a
>>>> brief explanation as to how the default oom_adj is set, and under what
>>>> conditions it is given -17 by default? Is this defined by the
>>>> application? I looked through the kernel source,
>>>> and noticed some of the code was defaulted to set oom_adj to
>>>> OOM_DISABLE (which is defined in the headers as -17).
>>>>
>>>> Assuming the debian problem is resolved, this might be another call
>>>> for the oom-killer to be modified so that if it encounters the
>>>> unrecoverable loop, it ignores the -17 rule (with some exceptions,
>>>> such as kernel processes, and other critical things). If this is going
>>>> to be a relatively simple task, I wouldn't mind spending a few hours
>>>> patching this?
>>>>
>>>> Cal
>>>>
>>>> On Mon, May 30, 2011 at 3:23 AM, KAMEZAWA Hiroyuki
>>>> <kamezawa.hiroyu@jp.fujitsu.com>  wrote:
>>>>> Thank you. memory cgroup and OOM troubles are handled in linux-mm.
>>>>>
>>>>> On Sun, 29 May 2011 23:24:07 +0100
>>>>> "Cal Leeming [Simplicity Media 
>>>>> Ltd]"<cal.leeming@simplicitymedialtd.co.uk>  wrote:
>>>>>
>>>>>> Some further logs:
>>>>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.369927] 
>>>>>> redis-server
>>>>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>>>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.369939]
>>>>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.399285] 
>>>>>> redis-server
>>>>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>>>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.399296]
>>>>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.428690] 
>>>>>> redis-server
>>>>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>>>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.428702]
>>>>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.487696] 
>>>>>> redis-server
>>>>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>>>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.487708]
>>>>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.517023] 
>>>>>> redis-server
>>>>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>>>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.517035]
>>>>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.546379] 
>>>>>> redis-server
>>>>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>>>>> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.546391]
>>>>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.310789] 
>>>>>> redis-server
>>>>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>>>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.310804]
>>>>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.369918] 
>>>>>> redis-server
>>>>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>>>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.369930]
>>>>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.399284] 
>>>>>> redis-server
>>>>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>>>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.399296]
>>>>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.433634] 
>>>>>> redis-server
>>>>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>>>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.433648]
>>>>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.463947] 
>>>>>> redis-server
>>>>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>>>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.463959]
>>>>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.493439] 
>>>>>> redis-server
>>>>>> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
>>>>>> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.493451]
>>>>>> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
>>>>>>
>>>>>>
>>>>> hmm, in short, applications has -17 oom_adj in default with 
>>>>> 2.6.32.41 ?
>>>>> AFAIK, no kernel has such crazy settings as default..
>>>>>
>>>>> Does your 2 kernel uses the same environment/distribution ?
>>>>>
>>>>> Thanks,
>>>>> -Kame
>>>>>
>>>>>> On 29/05/2011 22:50, Cal Leeming [Simplicity Media Ltd] wrote:
>>>>>>>   First of all, my apologies if I have submitted this problem to 
>>>>>>> the
>>>>>>> wrong place, spent 20 minutes trying to figure out where it 
>>>>>>> needs to
>>>>>>> be sent, and was still none the wiser.
>>>>>>>
>>>>>>> The problem is related to applying memory limitations within a 
>>>>>>> cgroup.
>>>>>>> If the OOM killer kicks in, it gets stuck in a loop where it 
>>>>>>> tries to
>>>>>>> kill a process which has an oom_adj of -17. This causes an infinite
>>>>>>> loop, which in turn locks up the system.
>>>>>>>
>>>>>>> May 30 03:13:08 vicky kernel: [ 1578.117055] Memory cgroup out of
>>>>>>> memory: kill process 6016 (java) score 0 or a child
>>>>>>> May 30 03:13:08 vicky kernel: [ 1578.117154] Memory cgroup out of
>>>>>>> memory: kill process 6016 (java) score 0 or a child
>>>>>>> May 30 03:13:08 vicky kernel: [ 1578.117248] Memory cgroup out of
>>>>>>> memory: kill process 6016 (java) score 0 or a child
>>>>>>> May 30 03:13:08 vicky kernel: [ 1578.117343] Memory cgroup out of
>>>>>>> memory: kill process 6016 (java) score 0 or a child
>>>>>>> May 30 03:13:08 vicky kernel: [ 1578.117441] Memory cgroup out of
>>>>>>> memory: kill process 6016 (java) score 0 or a child
>>>>>>>
>>>>>>>
>>>>>>>   root@vicky [/home/foxx]>  uname -a
>>>>>>> Linux vicky 2.6.32.41-grsec #3 SMP Mon May 30 02:34:43 BST 2011 
>>>>>>> x86_64
>>>>>>> GNU/Linux
>>>>>>> (this happens on both the grsec patched and non patched 
>>>>>>> 2.6.32.41 kernel)
>>>>>>>
>>>>>>> When this is encountered, the memory usage across the whole 
>>>>>>> server is
>>>>>>> still within limits (not even hitting swap).
>>>>>>>
>>>>>>> The memory configuration for the cgroup/lxc is:
>>>>>>> lxc.cgroup.memory.limit_in_bytes = 3000M
>>>>>>> lxc.cgroup.memory.memsw.limit_in_bytes = 3128M
>>>>>>>
>>>>>>> Now, what is even more strange, is that when running under the
>>>>>>> 2.6.32.28 kernel (both patched and unpatched), this problem doesn't
>>>>>>> happen. However, there is a slight difference between the two 
>>>>>>> kernels.
>>>>>>> The 2.6.32.28 kernel gives a default of 0 in the /proc/X/oom_adj,
>>>>>>> where as the 2.6.32.41 gives a default of -17. I suspect this is 
>>>>>>> the
>>>>>>> root cause of why it's showing in the later kernel, but not the 
>>>>>>> earlier.
>>>>>>>
>>>>>>> To test this theory, I started up the lxc on both servers, and then
>>>>>>> ran a one liner which showed me all the processes with an 
>>>>>>> oom_adj of -17:
>>>>>>>
>>>>>>> (the below is the older/working kernel)
>>>>>>> root@courtney.internal [/mnt/encstore/lxc]>  uname -a
>>>>>>> Linux courtney.internal 2.6.32.28-grsec #3 SMP Fri Feb 18 
>>>>>>> 16:09:07 GMT
>>>>>>> 2011 x86_64 GNU/Linux
>>>>>>> root@courtney.internal [/mnt/encstore/lxc]>  for x in `find /proc
>>>>>>> -iname 'oom_adj' | xargs grep "\-17"  | awk -F '/' '{print $3}'` 
>>>>>>> ; do
>>>>>>> ps -p $x --no-headers ; done
>>>>>>> grep: /proc/1411/task/1411/oom_adj: No such file or directory
>>>>>>> grep: /proc/1411/oom_adj: No such file or directory
>>>>>>>    804 ?        00:00:00 udevd
>>>>>>>    804 ?        00:00:00 udevd
>>>>>>> 25536 ?        00:00:00 sshd
>>>>>>> 25536 ?        00:00:00 sshd
>>>>>>> 31861 ?        00:00:00 sshd
>>>>>>> 31861 ?        00:00:00 sshd
>>>>>>> 32173 ?        00:00:00 udevd
>>>>>>> 32173 ?        00:00:00 udevd
>>>>>>> 32174 ?        00:00:00 udevd
>>>>>>> 32174 ?        00:00:00 udevd
>>>>>>>
>>>>>>> (the below is the newer/broken kernel)
>>>>>>>   root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41]>  uname -a
>>>>>>> Linux vicky 2.6.32.41-grsec #3 SMP Mon May 30 02:34:43 BST 2011 
>>>>>>> x86_64
>>>>>>> GNU/Linux
>>>>>>>   root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41]>  for x in
>>>>>>> `find /proc -iname 'oom_adj' | xargs grep "\-17"  | awk -F '/' 
>>>>>>> '{print
>>>>>>> $3}'` ; do ps -p $x --no-headers ; done
>>>>>>> grep: /proc/3118/task/3118/oom_adj: No such file or directory
>>>>>>> grep: /proc/3118/oom_adj: No such file or directory
>>>>>>>    895 ?        00:00:00 udevd
>>>>>>>    895 ?        00:00:00 udevd
>>>>>>>   1091 ?        00:00:00 udevd
>>>>>>>   1091 ?        00:00:00 udevd
>>>>>>>   1092 ?        00:00:00 udevd
>>>>>>>   1092 ?        00:00:00 udevd
>>>>>>>   2596 ?        00:00:00 sshd
>>>>>>>   2596 ?        00:00:00 sshd
>>>>>>>   2608 ?        00:00:00 sshd
>>>>>>>   2608 ?        00:00:00 sshd
>>>>>>>   2613 ?        00:00:00 sshd
>>>>>>>   2613 ?        00:00:00 sshd
>>>>>>>   2614 pts/0    00:00:00 bash
>>>>>>>   2614 pts/0    00:00:00 bash
>>>>>>>   2620 pts/0    00:00:00 sudo
>>>>>>>   2620 pts/0    00:00:00 sudo
>>>>>>>   2621 pts/0    00:00:00 su
>>>>>>>   2621 pts/0    00:00:00 su
>>>>>>>   2622 pts/0    00:00:00 bash
>>>>>>>   2622 pts/0    00:00:00 bash
>>>>>>>   2685 ?        00:00:00 lxc-start
>>>>>>>   2685 ?        00:00:00 lxc-start
>>>>>>>   2699 ?        00:00:00 init
>>>>>>>   2699 ?        00:00:00 init
>>>>>>>   2939 ?        00:00:00 rc
>>>>>>>   2939 ?        00:00:00 rc
>>>>>>>   2942 ?        00:00:00 startpar
>>>>>>>   2942 ?        00:00:00 startpar
>>>>>>>   2964 ?        00:00:00 rsyslogd
>>>>>>>   2964 ?        00:00:00 rsyslogd
>>>>>>>   2964 ?        00:00:00 rsyslogd
>>>>>>>   2964 ?        00:00:00 rsyslogd
>>>>>>>   2980 ?        00:00:00 startpar
>>>>>>>   2980 ?        00:00:00 startpar
>>>>>>>   2981 ?        00:00:00 ctlscript.sh
>>>>>>>   2981 ?        00:00:00 ctlscript.sh
>>>>>>>   3016 ?        00:00:00 cron
>>>>>>>   3016 ?        00:00:00 cron
>>>>>>>   3025 ?        00:00:00 mysqld_safe
>>>>>>>   3025 ?        00:00:00 mysqld_safe
>>>>>>>   3032 ?        00:00:00 sshd
>>>>>>>   3032 ?        00:00:00 sshd
>>>>>>>   3097 ?        00:00:00 mysqld.bin
>>>>>>>   3097 ?        00:00:00 mysqld.bin
>>>>>>>   3097 ?        00:00:00 mysqld.bin
>>>>>>>   3097 ?        00:00:00 mysqld.bin
>>>>>>>   3097 ?        00:00:00 mysqld.bin
>>>>>>>   3097 ?        00:00:00 mysqld.bin
>>>>>>>   3097 ?        00:00:00 mysqld.bin
>>>>>>>   3097 ?        00:00:00 mysqld.bin
>>>>>>>   3097 ?        00:00:00 mysqld.bin
>>>>>>>   3097 ?        00:00:00 mysqld.bin
>>>>>>>   3113 ?        00:00:00 ctl.sh
>>>>>>>   3113 ?        00:00:00 ctl.sh
>>>>>>>   3115 ?        00:00:00 sleep
>>>>>>>   3115 ?        00:00:00 sleep
>>>>>>>   3116 ?        00:00:00 .memcached.bin
>>>>>>>   3116 ?        00:00:00 .memcached.bin
>>>>>>>
>>>>>>>
>>>>>>> As you can see, it is clear that the newer kernel is setting -17 by
>>>>>>> default, which in turn is causing the OOM killer loop.
>>>>>>>
>>>>>>> So I began to try and find what may have caused this problem by
>>>>>>> comparing the two sources...
>>>>>>>
>>>>>>> I checked the code for all references to 'oom_adj' and 
>>>>>>> 'oom_adjust' in
>>>>>>> both code sets, but found no obvious differences:
>>>>>>> grep -R -e oom_adjust -e oom_adj . | sort | grep -R -e 
>>>>>>> oom_adjust -e
>>>>>>> oom_adj
>>>>>>>
>>>>>>> Then I checked for references to "-17" in all .c and .h files, and
>>>>>>> found a couple of matches, but only one obvious one:
>>>>>>> grep -R "\-17" . | grep -e ".c:" -e ".h:" -e "\-17" | wc -l
>>>>>>> ./include/linux/oom.h:#define OOM_DISABLE (-17)
>>>>>>>
>>>>>>> But again, a search for OOM_DISABLE came up with nothing obvious...
>>>>>>>
>>>>>>> In a last ditch attempt, I did a search for all references to 'oom'
>>>>>>> (case-insensitive) in both code bases, then compared the two:
>>>>>>>   root@annabelle [~/lol/linux-2.6.32.28]>  grep -i -R "oom" . | 
>>>>>>> sort -n
>>>>>>>> /tmp/annabelle.oom_adj
>>>>>>>   root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41]>  grep 
>>>>>>> -i -R
>>>>>>> "oom" . | sort -n>  /tmp/vicky.oom_adj
>>>>>>>
>>>>>>> and this brought back (yet again) nothing obvious..
>>>>>>>
>>>>>>>
>>>>>>>   root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41]>  md5sum
>>>>>>> ./include/linux/oom.h
>>>>>>> 2a32622f6cd38299fc2801d10a9a3ea8  ./include/linux/oom.h
>>>>>>>
>>>>>>>   root@annabelle [~/lol/linux-2.6.32.28]>  md5sum 
>>>>>>> ./include/linux/oom.h
>>>>>>> 2a32622f6cd38299fc2801d10a9a3ea8  ./include/linux/oom.h
>>>>>>>
>>>>>>>   root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41]>  md5sum
>>>>>>> ./mm/oom_kill.c
>>>>>>> 1ef2c2bec19868d13ec66ec22033f10a  ./mm/oom_kill.c
>>>>>>>
>>>>>>>   root@annabelle [~/lol/linux-2.6.32.28]>  md5sum ./mm/oom_kill.c
>>>>>>> 1ef2c2bec19868d13ec66ec22033f10a  ./mm/oom_kill.c
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> Could anyone please shed some light as to why the default 
>>>>>>> oom_adj is
>>>>>>> set to -17 now (and where it is actually set)? From what I can 
>>>>>>> tell,
>>>>>>> the fix for this issue will either be:
>>>>>>>
>>>>>>>    1. Allow OOM killer to override the decision of ignoring 
>>>>>>> oom_adj ==
>>>>>>>       -17 if an unrecoverable loop is encountered.
>>>>>>>    2. Change the default back to 0.
>>>>>>>
>>>>>>> Again, my apologies if this bug report is slightly unorthodox, or
>>>>>>> doesn't follow usual procedure etc. I can assure you I have 
>>>>>>> tried my
>>>>>>> absolute best to give all the necessary information though.
>>>>>>>
>>>>>>> Cal
>>>>>>>
>>>>>> -- 
>>>>>> To unsubscribe from this list: send the line "unsubscribe 
>>>>>> linux-kernel" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>>>>
>>>
>>
>


--------------040802070209080002020205
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#ffffff" text="#000000">
    This is now being handed back to linux-mm for re-assessment..
    OpenSSH devs are saying this is not a fault in their code..<br>
    <br>
    It would appear that the loadable bnx2 module is causing strange
    oom_adj behavior.. and if its affecting this, I wonder what else it
    might be affecting? Bug can only be reproduced when the module is in
    use by actual hardware.<br>
    <br>
    Here is the latest conversation with openssh devs, which confirms
    this definitely falls within the remit of debian or kernel-mm.
    <br>
    <br>
    On 31/05/2011 13:25, Gert Doering wrote:
    <br>
    &gt; Hi,
    <br>
    &gt;
    <br>
    &gt; On Tue, May 31, 2011 at 12:11:13PM +0100, Cal Leeming
    [Simplicity Media Ltd] wrote:
    <br>
    &gt;&gt; Could you point out the line of code where oom_adj_save is
    set to the
    <br>
    &gt;&gt; original value, because I've looked everywhere, and from
    what I can
    <br>
    &gt;&gt; tell, it's only ever set to INT_MIN, and no where else is
    it changed.
    <br>
    &gt;&gt; (C is not my strongest language tho, so I most likely have
    overlooked
    <br>
    &gt;&gt; something). This is where I got thrown off.
    <br>
    &gt;
    <br>
    &gt; oom_adjust_setup() does this:
    <br>
    &gt;
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if ((fp = fopen(oom_adj_path, "r+")) != NULL) {
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (fscanf(fp, "%d", &amp;oom_adj_save)
    != 1)
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; verbose("error reading %s: %s",
    oom_adj_path,
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; strerror(errno));
    <br>
    &gt;
    <br>
    &gt; the "fscanf()" call will read an integer ("%d") from the file
    named,
    <br>
    &gt; and write that number into the variable being pointed to
    (&amp;oom_adj_save).
    <br>
    &gt;
    <br>
    &gt; The loop is a bit tricky to read as it takes different paths
    into
    <br>
    &gt; account, and will exit after the first successful update.
    <br>
    &gt;
    <br>
    &gt; fscanf() will return the number of successful conversions, so
    if it
    <br>
    &gt; was able to read "one number", the return value is "1", and it
    will
    <br>
    &gt; jump to the else block
    <br>
    &gt;
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; else {
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rewind(fp);
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (fprintf(fp, "%d\n", value)
    &lt;= 0)
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; verbose("error writing
    %s: %s",
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; oom_adj_path,
    strerror(errno));
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; else
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; verbose("Set %s from %d
    to %d",
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; oom_adj_path,
    oom_adj_save, value);
    <br>
    &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }
    <br>
    &gt;
    <br>
    &gt; where it will overwrite what is in that file with the new value
    <br>
    &gt; ("value"), and then print the "Set ... from -17 to -17" message
    that
    <br>
    &gt; you saw.
    <br>
    <br>
    Ah, thank you for explaining this. Makes a lot more sense now <span
      class="moz-smiley-s1" title=":)"><span>:)</span></span>
    <br>
    <br>
    &gt;
    <br>
    &gt;
    <br>
    &gt;&gt;&gt; The question here is why sshd is sometimes started with
    -17 and sometimes
    <br>
    &gt;&gt;&gt; with 0 - that's the bug, not that sshd keeps what it's
    given.
    <br>
    &gt;&gt;&gt;
    <br>
    &gt;&gt;&gt; (Ask yourself: if sshd had no idea about oom_adj at
    all, would this make
    <br>
    &gt;&gt;&gt; it buggy by not changing the value?)
    <br>
    &gt;&gt;
    <br>
    &gt;&gt; This was what I was trying to pinpoint down before. I had
    came to this
    <br>
    &gt;&gt; conclusion myself, sent it to the Debian bug list, and they
    dismissed
    <br>
    &gt;&gt; on the grounds that it was an openssh problem...
    <br>
    &gt;
    <br>
    &gt; I must admit that I have no idea what is causing it, but from
    the logs,
    <br>
    &gt; it very much looks like sshd is started with "-17" in there -
    but only
    <br>
    &gt; in the problem case.
    <br>
    &gt;
    <br>
    &gt;
    <br>
    &gt;&gt; So far, the buck has been passed from kernel-mm to
    debian-kernel, to
    <br>
    &gt;&gt; openssh, and now back to debian-kernel lol. The most
    annoying thing,
    <br>
    &gt;&gt; is that you can't get this bug to happen unless you
    physically test on
    <br>
    &gt;&gt; a machine which requires the bnx2 firmwire, so I get the
    feeling this
    <br>
    &gt;&gt; won't get resolved :/
    <br>
    &gt;
    <br>
    &gt; And <b class="moz-txt-star"><span class="moz-txt-tag">*</span>that<span
        class="moz-txt-tag">*</span></b> strongly points to a bug in the
    bnx2 stuff - if other programs
    <br>
    &gt; change their behaviour based on the existance of a given
    driver, that
    <br>
    &gt; does not smell very healthy.
    <br>
    <br>
    Agreed.. I was thinking of adding some debug into the fs/proc/ code
    which does a kprint on every oom_adj read/write, but I couldn't
    figure out how to extract the pid from the task (pointer?).
    <br>
    <br>
    &gt;
    <br>
    &gt; [..]
    <br>
    &gt;&gt;&gt; Anyway, as a workaround for your system, you can
    certainly set
    <br>
    &gt;&gt;&gt;
    <br>
    &gt;&gt;&gt;&nbsp; oom_adj_save = 0;
    <br>
    &gt;&gt;&gt;
    <br>
    &gt;&gt;&gt; in the beginning of port-linux.c /
    oom_adjust_restore(), to claim that
    <br>
    &gt;&gt;&gt; "hey, this was the saved value to start with" and
    "restore" oom_adj to 0
    <br>
    &gt;&gt;&gt; then - but that's just hiding the bug, not fixing it.
    <br>
    &gt;&gt;
    <br>
    &gt;&gt; I'm disappointed this wasn't the correct fix, I honestly
    thought I had
    <br>
    &gt;&gt; patched it right <span class="moz-smiley-s2" title=":("><span>:(</span></span>
    <br>
    &gt;
    <br>
    &gt; Well, that's the short hand - "just ignore everything that
    happened at
    <br>
    &gt; init / save time, and forcibly write back '0', no matter what
    was there
    <br>
    &gt; before".
    <br>
    &gt;
    <br>
    &gt;&gt; But, on the other hand, ssh users should really never have
    a default
    <br>
    &gt;&gt; oom_adj of -17, so maybe 0 should be set as default anyway?
    If this is
    <br>
    &gt;&gt; not the case, could you give reasons why??
    <br>
    &gt;
    <br>
    &gt; Well, I would say "the default value in there is a matter of
    local policy",
    <br>
    &gt; so what if someone wants to make sure that whatever is run from
    sshd is
    <br>
    &gt; always privileged regarding oom, even if a local firefox etc.
    is running
    <br>
    &gt; amock and you need to ssh-in and kill the GUI stuff...
    <br>
    &gt;
    <br>
    &gt; One might opt to run sshd (and all its children) at "-5"
    (slightly special
    <br>
    &gt; treatment), or "0" (no special treatment), or even at "-17" -
    but that's
    <br>
    &gt; local policy.
    <br>
    <br>
    Ah, okay that's make sense.
    <br>
    <br>
    &gt;
    <br>
    &gt;
    <br>
    &gt; Mmmh.
    <br>
    &gt;
    <br>
    &gt; Since this seems to be inherited, it might even work if you
    just change
    <br>
    &gt; the sshd startup script, and insert
    <br>
    &gt;
    <br>
    &gt;&nbsp;&nbsp; echo 0 &gt;/proc/self/oom_adj
    <br>
    &gt;
    <br>
    &gt; in there, right before it starts the sshd...&nbsp; "local policy at
    work".
    <br>
    <br>
    Yeah I was going to do this, but then I thought "well if this
    problem is occurring for openssh, then what else could it be
    affecting?". As you pointed out above, having the oom_adj changed
    based on the existence of a driver is really not good.
    <br>
    <br>
    I will paste this convo trail into the debian ticket, and hopefully
    it'll help convince them this issue needs fixing.
    <br>
    <br>
    &gt;
    <br>
    &gt; gert
    <br>
    <br>
    Thanks again for taking the time to reply!
    <br>
    <br>
    <br>
    <br>
    On 30/05/2011 22:36, Cal Leeming [Simplicity Media Ltd] wrote:
    <blockquote cite="mid:4DE40DCA.3000909@simplicitymedialtd.co.uk"
      type="cite">FYI everyone, I found a bug within openssh-server
      which caused this problem.
      <br>
      <br>
      I've patched and submitted to the openssh list.
      <br>
      <br>
      You can find details of this by googling for:
      <br>
      "port-linux.c bug with oom_adjust_restore() - causes real bad
      oom_adj - which can cause DoS conditions"
      <br>
      <br>
      It's extremely strange.. :S
      <br>
      <br>
      Cal
      <br>
      <br>
      On 30/05/2011 18:36, Cal Leeming [Simplicity Media Ltd] wrote:
      <br>
      <blockquote type="cite">Here is an strace of the SSH process
        (which is somehow inheriting the -17 oom_adj on all forked user
        instances)
        <br>
        <br>
        (broken server - with bnx2 module loaded)
        <br>
        [pid&nbsp; 2200] [&nbsp;&nbsp;&nbsp; 7f13a09c9cb0] open("/proc/self/oom_adj",
        O_WRONLY|O_CREAT|O_TRUNC, 0666 &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 2120] [&nbsp;&nbsp;&nbsp; 7f13a09c9f00] write(7, "\0\0\2\240\n\n\n\nPort
        22\n\n\n\nProtocol 2\n\nH"..., 680 &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 2200] [&nbsp;&nbsp;&nbsp; 7f13a09c9cb0] &lt;... open resumed&gt; ) = 9
        <br>
        [pid&nbsp; 2120] [&nbsp;&nbsp;&nbsp; 7f13a09c9f00] &lt;... write resumed&gt; ) = 680
        <br>
        [pid&nbsp; 2120] [&nbsp;&nbsp;&nbsp; 7f13a09c9e40] close(7 &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 2200] [&nbsp;&nbsp;&nbsp; 7f13a09c9844] fstat(9, &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 2120] [&nbsp;&nbsp;&nbsp; 7f13a09c9e40] &lt;... close resumed&gt; ) = 0
        <br>
        [pid&nbsp; 2200] [&nbsp;&nbsp;&nbsp; 7f13a09c9844] &lt;... fstat resumed&gt;
        {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
        <br>
        [pid&nbsp; 2120] [&nbsp;&nbsp;&nbsp; 7f13a09c9e40] close(8 &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 2200] [&nbsp;&nbsp;&nbsp; 7f13a09d2a2a] mmap(NULL, 4096,
        PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0
        &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 2120] [&nbsp;&nbsp;&nbsp; 7f13a09c9e40] &lt;... close resumed&gt; ) = 0
        <br>
        [pid&nbsp; 2200] [&nbsp;&nbsp;&nbsp; 7f13a09d2a2a] &lt;... mmap resumed&gt; ) =
        0x7f13a25a6000
        <br>
        [pid&nbsp; 2120] [&nbsp;&nbsp;&nbsp; 7f13a09c9e40] close(4 &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 2200] [&nbsp;&nbsp;&nbsp; 7f13a09c9f00] write(9, "-17\n", 4
        &lt;unfinished ...&gt;
        <br>
        <br>
        <br>
        (working server - with bnx2 module unloaded)
        <br>
        [pid&nbsp; 1323] [&nbsp;&nbsp;&nbsp; 7fae577fbe40] close(7) = 0
        <br>
        [pid&nbsp; 1631] [&nbsp;&nbsp;&nbsp; 7fae577fbcb0] open("/proc/self/oom_adj",
        O_WRONLY|O_CREAT|O_TRUNC, 0666 &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 1323] [&nbsp;&nbsp;&nbsp; 7fae577fbf00] write(8, "\0\0\2\217\0", 5
        &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 1631] [&nbsp;&nbsp;&nbsp; 7fae577fbcb0] &lt;... open resumed&gt; ) = 10
        <br>
        [pid&nbsp; 1323] [&nbsp;&nbsp;&nbsp; 7fae577fbf00] &lt;... write resumed&gt; ) = 5
        <br>
        [pid&nbsp; 1323] [&nbsp;&nbsp;&nbsp; 7fae577fbf00] write(8, "\0\0\2\206\n\n\n\nPort
        22\n\n\n\nProtocol 2\n\nH"..., 654 &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 1631] [&nbsp;&nbsp;&nbsp; 7fae577fb844] fstat(10, &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 1323] [&nbsp;&nbsp;&nbsp; 7fae577fbf00] &lt;... write resumed&gt; ) = 654
        <br>
        [pid&nbsp; 1631] [&nbsp;&nbsp;&nbsp; 7fae577fb844] &lt;... fstat resumed&gt;
        {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
        <br>
        [pid&nbsp; 1323] [&nbsp;&nbsp;&nbsp; 7fae577fbe40] close(8) = 0
        <br>
        [pid&nbsp; 1631] [&nbsp;&nbsp;&nbsp; 7fae57804a2a] mmap(NULL, 4096,
        PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0
        &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 1323] [&nbsp;&nbsp;&nbsp; 7fae577fbe40] close(9 &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 1631] [&nbsp;&nbsp;&nbsp; 7fae57804a2a] &lt;... mmap resumed&gt; ) =
        0x7fae593d9000
        <br>
        [pid&nbsp; 1323] [&nbsp;&nbsp;&nbsp; 7fae577fbe40] &lt;... close resumed&gt; ) = 0
        <br>
        [pid&nbsp; 1323] [&nbsp;&nbsp;&nbsp; 7fae577fbe40] close(5 &lt;unfinished ...&gt;
        <br>
        [pid&nbsp; 1631] [&nbsp;&nbsp;&nbsp; 7fae577fbf00] write(10, "0\n", 2 &lt;unfinished
        ...&gt;
        <br>
        <br>
        The two servers are *EXACT* duplicates of each other, completely
        fresh Debian installs, with exactly the same packages installed.
        <br>
        <br>
        As you can see, the working server sends "0" into the oom_adj
        and the broken one sends "-17".
        <br>
        <br>
        <br>
        On 30/05/2011 15:27, Cal Leeming [Simplicity Media Ltd] wrote:
        <br>
        <blockquote type="cite">I FOUND THE PROBLEM!!!
          <br>
          <br>
          Explicit details can be found on the Debian kernel mailing
          list, but to cut short, it's caused by the firmware-bnx2
          kernel module:
          <br>
          <br>
          The broken server uses 'firmware-bnx2'.. so I purged the bnx2
          package, removed the bnx*.ko files from /lib/modules, ran
          update-initramfs, and then rebooted (i then confirmed it was
          removed by checking ifconfig and lsmod).
          <br>
          <br>
          And guess what.. IT WORKED.
          <br>
          <br>
          So, this problem seems to be caused by the firmware-bnx2
          module being loaded.. some how, that module is causing -17
          oom_adj to be set for everything..
          <br>
          <br>
          WTF?!?! Surely a bug?? Could someone please forward this to
          the appropriate person for the bnx2 kernel module, as I
          wouldn't even know where to begin :S
          <br>
          <br>
          Cal
          <br>
          <br>
          On 30/05/2011 11:52, Cal Leeming [Simplicity Media Ltd] wrote:
          <br>
          <blockquote type="cite">-resent due to incorrect formatting,
            sorry if this dups!
            <br>
            <br>
            @Kame
            <br>
            Thanks for the reply!
            <br>
            Both kernels used the same env/dist, but which slightly
            different packages.
            <br>
            After many frustrating hours, I have pin pointed this down
            to a dodgy
            <br>
            Debian package which appears to continue affecting the
            system, even
            <br>
            after purging. I'm still yet to pin point the package down
            (I'm doing
            <br>
            several reinstall tests, along with tripwire analysis after
            each
            <br>
            reboot).
            <br>
            <br>
            @Hiroyuki
            <br>
            Thank you for sending this to the right people!
            <br>
            <br>
            @linux-mm
            <br>
            On a side note, would someone mind taking a few minutes to
            give a
            <br>
            brief explanation as to how the default oom_adj is set, and
            under what
            <br>
            conditions it is given -17 by default? Is this defined by
            the
            <br>
            application? I looked through the kernel source,
            <br>
            and noticed some of the code was defaulted to set oom_adj to
            <br>
            OOM_DISABLE (which is defined in the headers as -17).
            <br>
            <br>
            Assuming the debian problem is resolved, this might be
            another call
            <br>
            for the oom-killer to be modified so that if it encounters
            the
            <br>
            unrecoverable loop, it ignores the -17 rule (with some
            exceptions,
            <br>
            such as kernel processes, and other critical things). If
            this is going
            <br>
            to be a relatively simple task, I wouldn't mind spending a
            few hours
            <br>
            patching this?
            <br>
            <br>
            Cal
            <br>
            <br>
            On Mon, May 30, 2011 at 3:23 AM, KAMEZAWA Hiroyuki
            <br>
            <a class="moz-txt-link-rfc2396E" href="mailto:kamezawa.hiroyu@jp.fujitsu.com">&lt;kamezawa.hiroyu@jp.fujitsu.com&gt;</a>&nbsp; wrote:
            <br>
            <blockquote type="cite">Thank you. memory cgroup and OOM
              troubles are handled in linux-mm.
              <br>
              <br>
              On Sun, 29 May 2011 23:24:07 +0100
              <br>
              "Cal Leeming [Simplicity Media
              Ltd]"<a class="moz-txt-link-rfc2396E" href="mailto:cal.leeming@simplicitymedialtd.co.uk">&lt;cal.leeming@simplicitymedialtd.co.uk&gt;</a>&nbsp; wrote:
              <br>
              <br>
              <blockquote type="cite">Some further logs:
                <br>
                ./log/syslog:May 30 07:44:38 vicky kernel: [
                2283.369927] redis-server
                <br>
                invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
                <br>
                ./log/syslog:May 30 07:44:38 vicky kernel: [
                2283.369939]
                <br>
                [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283
                <br>
                ./log/syslog:May 30 07:44:38 vicky kernel: [
                2283.399285] redis-server
                <br>
                invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
                <br>
                ./log/syslog:May 30 07:44:38 vicky kernel: [
                2283.399296]
                <br>
                [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283
                <br>
                ./log/syslog:May 30 07:44:38 vicky kernel: [
                2283.428690] redis-server
                <br>
                invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
                <br>
                ./log/syslog:May 30 07:44:38 vicky kernel: [
                2283.428702]
                <br>
                [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283
                <br>
                ./log/syslog:May 30 07:44:38 vicky kernel: [
                2283.487696] redis-server
                <br>
                invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
                <br>
                ./log/syslog:May 30 07:44:38 vicky kernel: [
                2283.487708]
                <br>
                [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283
                <br>
                ./log/syslog:May 30 07:44:38 vicky kernel: [
                2283.517023] redis-server
                <br>
                invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
                <br>
                ./log/syslog:May 30 07:44:38 vicky kernel: [
                2283.517035]
                <br>
                [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283
                <br>
                ./log/syslog:May 30 07:44:38 vicky kernel: [
                2283.546379] redis-server
                <br>
                invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
                <br>
                ./log/syslog:May 30 07:44:38 vicky kernel: [
                2283.546391]
                <br>
                [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283
                <br>
                ./log/syslog:May 30 07:44:43 vicky kernel: [
                2288.310789] redis-server
                <br>
                invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
                <br>
                ./log/syslog:May 30 07:44:43 vicky kernel: [
                2288.310804]
                <br>
                [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283
                <br>
                ./log/syslog:May 30 07:44:43 vicky kernel: [
                2288.369918] redis-server
                <br>
                invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
                <br>
                ./log/syslog:May 30 07:44:43 vicky kernel: [
                2288.369930]
                <br>
                [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283
                <br>
                ./log/syslog:May 30 07:44:43 vicky kernel: [
                2288.399284] redis-server
                <br>
                invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
                <br>
                ./log/syslog:May 30 07:44:43 vicky kernel: [
                2288.399296]
                <br>
                [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283
                <br>
                ./log/syslog:May 30 07:44:43 vicky kernel: [
                2288.433634] redis-server
                <br>
                invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
                <br>
                ./log/syslog:May 30 07:44:43 vicky kernel: [
                2288.433648]
                <br>
                [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283
                <br>
                ./log/syslog:May 30 07:44:43 vicky kernel: [
                2288.463947] redis-server
                <br>
                invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
                <br>
                ./log/syslog:May 30 07:44:43 vicky kernel: [
                2288.463959]
                <br>
                [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283
                <br>
                ./log/syslog:May 30 07:44:43 vicky kernel: [
                2288.493439] redis-server
                <br>
                invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
                <br>
                ./log/syslog:May 30 07:44:43 vicky kernel: [
                2288.493451]
                <br>
                [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283
                <br>
                <br>
                <br>
              </blockquote>
              hmm, in short, applications has -17 oom_adj in default
              with 2.6.32.41 ?
              <br>
              AFAIK, no kernel has such crazy settings as default..
              <br>
              <br>
              Does your 2 kernel uses the same environment/distribution
              ?
              <br>
              <br>
              Thanks,
              <br>
              -Kame
              <br>
              <br>
              <blockquote type="cite">On 29/05/2011 22:50, Cal Leeming
                [Simplicity Media Ltd] wrote:
                <br>
                <blockquote type="cite">&nbsp; First of all, my apologies if
                  I have submitted this problem to the
                  <br>
                  wrong place, spent 20 minutes trying to figure out
                  where it needs to
                  <br>
                  be sent, and was still none the wiser.
                  <br>
                  <br>
                  The problem is related to applying memory limitations
                  within a cgroup.
                  <br>
                  If the OOM killer kicks in, it gets stuck in a loop
                  where it tries to
                  <br>
                  kill a process which has an oom_adj of -17. This
                  causes an infinite
                  <br>
                  loop, which in turn locks up the system.
                  <br>
                  <br>
                  May 30 03:13:08 vicky kernel: [ 1578.117055] Memory
                  cgroup out of
                  <br>
                  memory: kill process 6016 (java) score 0 or a child
                  <br>
                  May 30 03:13:08 vicky kernel: [ 1578.117154] Memory
                  cgroup out of
                  <br>
                  memory: kill process 6016 (java) score 0 or a child
                  <br>
                  May 30 03:13:08 vicky kernel: [ 1578.117248] Memory
                  cgroup out of
                  <br>
                  memory: kill process 6016 (java) score 0 or a child
                  <br>
                  May 30 03:13:08 vicky kernel: [ 1578.117343] Memory
                  cgroup out of
                  <br>
                  memory: kill process 6016 (java) score 0 or a child
                  <br>
                  May 30 03:13:08 vicky kernel: [ 1578.117441] Memory
                  cgroup out of
                  <br>
                  memory: kill process 6016 (java) score 0 or a child
                  <br>
                  <br>
                  <br>
                  &nbsp; root@vicky [/home/foxx]&gt;&nbsp; uname -a
                  <br>
                  Linux vicky 2.6.32.41-grsec #3 SMP Mon May 30 02:34:43
                  BST 2011 x86_64
                  <br>
                  GNU/Linux
                  <br>
                  (this happens on both the grsec patched and non
                  patched 2.6.32.41 kernel)
                  <br>
                  <br>
                  When this is encountered, the memory usage across the
                  whole server is
                  <br>
                  still within limits (not even hitting swap).
                  <br>
                  <br>
                  The memory configuration for the cgroup/lxc is:
                  <br>
                  lxc.cgroup.memory.limit_in_bytes = 3000M
                  <br>
                  lxc.cgroup.memory.memsw.limit_in_bytes = 3128M
                  <br>
                  <br>
                  Now, what is even more strange, is that when running
                  under the
                  <br>
                  2.6.32.28 kernel (both patched and unpatched), this
                  problem doesn't
                  <br>
                  happen. However, there is a slight difference between
                  the two kernels.
                  <br>
                  The 2.6.32.28 kernel gives a default of 0 in the
                  /proc/X/oom_adj,
                  <br>
                  where as the 2.6.32.41 gives a default of -17. I
                  suspect this is the
                  <br>
                  root cause of why it's showing in the later kernel,
                  but not the earlier.
                  <br>
                  <br>
                  To test this theory, I started up the lxc on both
                  servers, and then
                  <br>
                  ran a one liner which showed me all the processes with
                  an oom_adj of -17:
                  <br>
                  <br>
                  (the below is the older/working kernel)
                  <br>
                  <a class="moz-txt-link-abbreviated" href="mailto:root@courtney.internal">root@courtney.internal</a> [/mnt/encstore/lxc]&gt;&nbsp; uname
                  -a
                  <br>
                  Linux courtney.internal 2.6.32.28-grsec #3 SMP Fri Feb
                  18 16:09:07 GMT
                  <br>
                  2011 x86_64 GNU/Linux
                  <br>
                  <a class="moz-txt-link-abbreviated" href="mailto:root@courtney.internal">root@courtney.internal</a> [/mnt/encstore/lxc]&gt;&nbsp; for x
                  in `find /proc
                  <br>
                  -iname 'oom_adj' | xargs grep "\-17"&nbsp; | awk -F '/'
                  '{print $3}'` ; do
                  <br>
                  ps -p $x --no-headers ; done
                  <br>
                  grep: /proc/1411/task/1411/oom_adj: No such file or
                  directory
                  <br>
                  grep: /proc/1411/oom_adj: No such file or directory
                  <br>
                  &nbsp;&nbsp; 804 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 udevd
                  <br>
                  &nbsp;&nbsp; 804 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 udevd
                  <br>
                  25536 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sshd
                  <br>
                  25536 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sshd
                  <br>
                  31861 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sshd
                  <br>
                  31861 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sshd
                  <br>
                  32173 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 udevd
                  <br>
                  32173 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 udevd
                  <br>
                  32174 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 udevd
                  <br>
                  32174 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 udevd
                  <br>
                  <br>
                  (the below is the newer/broken kernel)
                  <br>
                  &nbsp; root@vicky
                  [/mnt/encstore/ssd/kernel/linux-2.6.32.41]&gt;&nbsp; uname
                  -a
                  <br>
                  Linux vicky 2.6.32.41-grsec #3 SMP Mon May 30 02:34:43
                  BST 2011 x86_64
                  <br>
                  GNU/Linux
                  <br>
                  &nbsp; root@vicky
                  [/mnt/encstore/ssd/kernel/linux-2.6.32.41]&gt;&nbsp; for x
                  in
                  <br>
                  `find /proc -iname 'oom_adj' | xargs grep "\-17"&nbsp; |
                  awk -F '/' '{print
                  <br>
                  $3}'` ; do ps -p $x --no-headers ; done
                  <br>
                  grep: /proc/3118/task/3118/oom_adj: No such file or
                  directory
                  <br>
                  grep: /proc/3118/oom_adj: No such file or directory
                  <br>
                  &nbsp;&nbsp; 895 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 udevd
                  <br>
                  &nbsp;&nbsp; 895 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 udevd
                  <br>
                  &nbsp; 1091 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 udevd
                  <br>
                  &nbsp; 1091 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 udevd
                  <br>
                  &nbsp; 1092 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 udevd
                  <br>
                  &nbsp; 1092 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 udevd
                  <br>
                  &nbsp; 2596 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sshd
                  <br>
                  &nbsp; 2596 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sshd
                  <br>
                  &nbsp; 2608 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sshd
                  <br>
                  &nbsp; 2608 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sshd
                  <br>
                  &nbsp; 2613 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sshd
                  <br>
                  &nbsp; 2613 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sshd
                  <br>
                  &nbsp; 2614 pts/0&nbsp;&nbsp;&nbsp; 00:00:00 bash
                  <br>
                  &nbsp; 2614 pts/0&nbsp;&nbsp;&nbsp; 00:00:00 bash
                  <br>
                  &nbsp; 2620 pts/0&nbsp;&nbsp;&nbsp; 00:00:00 sudo
                  <br>
                  &nbsp; 2620 pts/0&nbsp;&nbsp;&nbsp; 00:00:00 sudo
                  <br>
                  &nbsp; 2621 pts/0&nbsp;&nbsp;&nbsp; 00:00:00 su
                  <br>
                  &nbsp; 2621 pts/0&nbsp;&nbsp;&nbsp; 00:00:00 su
                  <br>
                  &nbsp; 2622 pts/0&nbsp;&nbsp;&nbsp; 00:00:00 bash
                  <br>
                  &nbsp; 2622 pts/0&nbsp;&nbsp;&nbsp; 00:00:00 bash
                  <br>
                  &nbsp; 2685 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 lxc-start
                  <br>
                  &nbsp; 2685 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 lxc-start
                  <br>
                  &nbsp; 2699 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 init
                  <br>
                  &nbsp; 2699 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 init
                  <br>
                  &nbsp; 2939 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 rc
                  <br>
                  &nbsp; 2939 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 rc
                  <br>
                  &nbsp; 2942 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 startpar
                  <br>
                  &nbsp; 2942 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 startpar
                  <br>
                  &nbsp; 2964 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 rsyslogd
                  <br>
                  &nbsp; 2964 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 rsyslogd
                  <br>
                  &nbsp; 2964 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 rsyslogd
                  <br>
                  &nbsp; 2964 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 rsyslogd
                  <br>
                  &nbsp; 2980 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 startpar
                  <br>
                  &nbsp; 2980 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 startpar
                  <br>
                  &nbsp; 2981 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 ctlscript.sh
                  <br>
                  &nbsp; 2981 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 ctlscript.sh
                  <br>
                  &nbsp; 3016 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 cron
                  <br>
                  &nbsp; 3016 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 cron
                  <br>
                  &nbsp; 3025 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 mysqld_safe
                  <br>
                  &nbsp; 3025 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 mysqld_safe
                  <br>
                  &nbsp; 3032 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sshd
                  <br>
                  &nbsp; 3032 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sshd
                  <br>
                  &nbsp; 3097 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 mysqld.bin
                  <br>
                  &nbsp; 3097 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 mysqld.bin
                  <br>
                  &nbsp; 3097 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 mysqld.bin
                  <br>
                  &nbsp; 3097 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 mysqld.bin
                  <br>
                  &nbsp; 3097 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 mysqld.bin
                  <br>
                  &nbsp; 3097 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 mysqld.bin
                  <br>
                  &nbsp; 3097 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 mysqld.bin
                  <br>
                  &nbsp; 3097 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 mysqld.bin
                  <br>
                  &nbsp; 3097 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 mysqld.bin
                  <br>
                  &nbsp; 3097 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 mysqld.bin
                  <br>
                  &nbsp; 3113 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 ctl.sh
                  <br>
                  &nbsp; 3113 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 ctl.sh
                  <br>
                  &nbsp; 3115 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sleep
                  <br>
                  &nbsp; 3115 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 sleep
                  <br>
                  &nbsp; 3116 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 .memcached.bin
                  <br>
                  &nbsp; 3116 ?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 00:00:00 .memcached.bin
                  <br>
                  <br>
                  <br>
                  As you can see, it is clear that the newer kernel is
                  setting -17 by
                  <br>
                  default, which in turn is causing the OOM killer loop.
                  <br>
                  <br>
                  So I began to try and find what may have caused this
                  problem by
                  <br>
                  comparing the two sources...
                  <br>
                  <br>
                  I checked the code for all references to 'oom_adj' and
                  'oom_adjust' in
                  <br>
                  both code sets, but found no obvious differences:
                  <br>
                  grep -R -e oom_adjust -e oom_adj . | sort | grep -R -e
                  oom_adjust -e
                  <br>
                  oom_adj
                  <br>
                  <br>
                  Then I checked for references to "-17" in all .c and
                  .h files, and
                  <br>
                  found a couple of matches, but only one obvious one:
                  <br>
                  grep -R "\-17" . | grep -e ".c:" -e ".h:" -e "\-17" |
                  wc -l
                  <br>
                  ./include/linux/oom.h:#define OOM_DISABLE (-17)
                  <br>
                  <br>
                  But again, a search for OOM_DISABLE came up with
                  nothing obvious...
                  <br>
                  <br>
                  In a last ditch attempt, I did a search for all
                  references to 'oom'
                  <br>
                  (case-insensitive) in both code bases, then compared
                  the two:
                  <br>
                  &nbsp; root@annabelle [~/lol/linux-2.6.32.28]&gt;&nbsp; grep -i
                  -R "oom" . | sort -n
                  <br>
                  <blockquote type="cite">/tmp/annabelle.oom_adj
                    <br>
                  </blockquote>
                  &nbsp; root@vicky
                  [/mnt/encstore/ssd/kernel/linux-2.6.32.41]&gt;&nbsp; grep
                  -i -R
                  <br>
                  "oom" . | sort -n&gt;&nbsp; /tmp/vicky.oom_adj
                  <br>
                  <br>
                  and this brought back (yet again) nothing obvious..
                  <br>
                  <br>
                  <br>
                  &nbsp; root@vicky
                  [/mnt/encstore/ssd/kernel/linux-2.6.32.41]&gt;&nbsp; md5sum
                  <br>
                  ./include/linux/oom.h
                  <br>
                  2a32622f6cd38299fc2801d10a9a3ea8&nbsp;
                  ./include/linux/oom.h
                  <br>
                  <br>
                  &nbsp; root@annabelle [~/lol/linux-2.6.32.28]&gt;&nbsp; md5sum
                  ./include/linux/oom.h
                  <br>
                  2a32622f6cd38299fc2801d10a9a3ea8&nbsp;
                  ./include/linux/oom.h
                  <br>
                  <br>
                  &nbsp; root@vicky
                  [/mnt/encstore/ssd/kernel/linux-2.6.32.41]&gt;&nbsp; md5sum
                  <br>
                  ./mm/oom_kill.c
                  <br>
                  1ef2c2bec19868d13ec66ec22033f10a&nbsp; ./mm/oom_kill.c
                  <br>
                  <br>
                  &nbsp; root@annabelle [~/lol/linux-2.6.32.28]&gt;&nbsp; md5sum
                  ./mm/oom_kill.c
                  <br>
                  1ef2c2bec19868d13ec66ec22033f10a&nbsp; ./mm/oom_kill.c
                  <br>
                  <br>
                  <br>
                  <br>
                  Could anyone please shed some light as to why the
                  default oom_adj is
                  <br>
                  set to -17 now (and where it is actually set)? From
                  what I can tell,
                  <br>
                  the fix for this issue will either be:
                  <br>
                  <br>
                  &nbsp;&nbsp; 1. Allow OOM killer to override the decision of
                  ignoring oom_adj ==
                  <br>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -17 if an unrecoverable loop is encountered.
                  <br>
                  &nbsp;&nbsp; 2. Change the default back to 0.
                  <br>
                  <br>
                  Again, my apologies if this bug report is slightly
                  unorthodox, or
                  <br>
                  doesn't follow usual procedure etc. I can assure you I
                  have tried my
                  <br>
                  absolute best to give all the necessary information
                  though.
                  <br>
                  <br>
                  Cal
                  <br>
                  <br>
                </blockquote>
                --&nbsp;<br>
                To unsubscribe from this list: send the line
                "unsubscribe linux-kernel" in
                <br>
                the body of a message to <a class="moz-txt-link-abbreviated" href="mailto:majordomo@vger.kernel.org">majordomo@vger.kernel.org</a>
                <br>
                More majordomo info at&nbsp;
                <a class="moz-txt-link-freetext" href="http://vger.kernel.org/majordomo-info.html">http://vger.kernel.org/majordomo-info.html</a>
                <br>
                Please read the FAQ at&nbsp; <a class="moz-txt-link-freetext" href="http://www.tux.org/lkml/">http://www.tux.org/lkml/</a>
                <br>
                <br>
              </blockquote>
            </blockquote>
          </blockquote>
          <br>
        </blockquote>
        <br>
      </blockquote>
      <br>
    </blockquote>
    <br>
  </body>
</html>

--------------040802070209080002020205--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
