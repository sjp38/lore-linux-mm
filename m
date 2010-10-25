Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 18DDD8D0002
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 16:57:54 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9PKkpjc022043
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 14:46:51 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9PKvn70136342
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 14:57:49 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9PL1igF022866
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 15:01:44 -0600
From: Antonio Rosales <rosalesa@austin.ibm.com>
Content-Type: multipart/alternative; boundary=Apple-Mail-1-495423215
Subject: OOM Killer cannot be invoked in a diskless environment to relieve severe memory pressure
Date: Mon, 25 Oct 2010 15:57:48 -0500
Message-Id: <5028E67C-A64E-4BA6-929C-36697B4CC5CF@austin.ibm.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


--Apple-Mail-1-495423215
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

I have been running into an interesting problem with the Out Of Memory =
Killer in a diskless environment running a 2.6.34.7-56 Fedora x86 based =
kernel.

It seems in a diskless environment the OOM Killer is not being invoked =
when the system is under severe memory pressure.  As a result the system =
hard hangs.

To investigate this issue further I made a System Tap Debug Fedora 13 =
live dvd  so I could gather in-line function probing of the OOM code =
path when testing in a disk-less environment to confirm if the OOM =
killer was invoked.

I also logged some memory statistics. If anyone is interested I have =
attached the debug files and logs to kernel.org bug:
https://bugzilla.kernel.org/show_bug.cgi?id=3D20792

-----------------------------
Testing: _with_ a disk
-----------------------------

A ran the c program from=20
=
http://linuxdevcenter.com/pub/a/linux/2006/11/30/linux-out-of-memory.html
with the addition to print out mallinfo and /proc/meminfo statistics.

The objective of the mem-pressure.c is to allocate huge blocks and fill =
them with 1s until the OOM killer is invoked and kills of offending =
process to rescue the system from memory pressure.

The test program successfully created memory pressure on the Fedora 13 =
system and caused the OOM killer to kill off offending process according =
to their calculated "badness" score.  In my test runs if mem-pressure =
wasn't killed directly then gnome, metacity, or the shell were killed =
which in turn killed mem-pressure.

The SystemTap script, oom.stp, shows the system going through the code =
sequence leading up to the OOM killer:
|> __alloc_pages_may_oom()
        |> out_of_memory()
                |> oom_kill_process()
                        |>oom_kill_task()
                                |>__oom_kill_task()

[Note: I removed probing __alloc_pages_slowpath() from oom.stp =
disk-environment testing to make the oom-stp.out log a little simpler to =
read.]

=3D=3D=3DAnalysis=3D=3D=3D
No surprises here.  With an attached disk the OOM killer was able to be =
invoked and relive the memory pressure returning the system to a =
~functioning state.  With the oom.stp script we can see the system =
following the code path to invoke the OOM killer.=20

[Note in some of my test runs I noticed some other services were killed =
before mem-pressure leading to a somewhat crippled system, but the main =
point is the system did _not_ hang.]

-Test data-
See the oom-test-data.tar.gz: OOM_testing/disk for test results using a =
disk environment.  OOM_testing/test/code has the scripts, and test =
program. I compiled the c program as mem-pressure, and logged the output =
to mem-pressure.out. In this sequence of testing I did not adjust any =
oom_adj values.  I also collected various memory statistics every second =
using the meminfo.sh script, and logged the output to meminfo.out. =
meminfo.out shows the
system's memory resources being used, and mem-pressure.out shows the =
consumption of memory resources by the mem-pressure program. The =
SystemTap script, oom.stp, output was logged to oom-stp.out

-----------------------------
Testing: _NO_ a disk (disk-less environment)
-----------------------------

I booted the Fedora 13 live dvd with SystemTap and kernel debuginfo rpms =
added to ensure a disk-less environment.

-Additions to the test program and scripts-
I ran the same mem-pressure from testing with a disk, but I added code =
to set the oom_adj value of mem-pressure to 15 to ensure if the OOM =
killer was invoked it would first kill the mem-pressure program.

I also added  __alloc_pages_slowpath() function to the oom.stp SystemTap =
script to show more of the memory allocation code path leading up to OOM =
killer.

The test program mem-pressure still successfully creates memory =
pressure, and as in previous testing the system hard hangs when system =
memory resources have been exhausted.

=3D=3D=3DAnalysis=3D=3D=3D
The system hard hangs after memory resources have been exhausted  by =
mem-pressure.  Probing the code path:
__alloc_pages_slowpath()
        |> __alloc_pages_may_oom()
                |> out_of_memory()
                        |> oom_kill_process() oom_kill_process
                                |>oom_kill_task
                                        |>__oom_kill_task

I see the system accessing alloc_pages_slowpath(), however I never see =
the system enter into out_of_memory(), and thus __oom_kill_task is not =
invoked to kill the mem-pressure processes. Consequently the system is =
unable to relive the memory pressure, and the system hard hangs.

-Test Data-
See the oom-test-data.tar.gz:  OOM_testing/NO_disk for test results =
using a disk-less environment.  OOM_testing/test/code has the scripts, =
test program, and kickstart files.

The same test data was collected as in the disk-enviroment.  I also =
added the kickstart files I used to make the Fedora 13 SystemTap Debug =
live dvd.  If your interested the instructions to create a Fedora Live =
CD are at:
http://fedoraproject.org/wiki/How_to_create_and_use_a_Live_CD
With the kickstarts provided one would run:
        livecd-creator \
                --config=3D/path/to/kickstartsfedora-livecd-desktop.ks \
                --fslabel=3DFedora-LiveCD-Debug --cache=3D/var/cache/live

(Note: I logged output to a mounted USB 2.0 flash drive.)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

In summary, the test results show the OOM Killer not being invoked in =
the disk-less environment to relive memory pressure causing the system =
to hard hang. This may very well be a by-product of running a diskless =
environment and overcommitting memory resources. =20

Any insights into this issue are welcomed.
-Thanks

--
Antonio Rosales
IBM Linux Technology Center


--Apple-Mail-1-495423215
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space; =
"><div>I have been running into an interesting problem with the Out Of =
Memory Killer in a diskless environment running a 2.6.34.7-56 Fedora x86 =
based kernel.</div><div><br></div><div>It seems in a diskless =
environment the OOM Killer is not being invoked when the system is under =
severe memory pressure. &nbsp;As a result the system hard =
hangs.</div><div><br></div><div>To investigate this issue further I made =
a System Tap Debug Fedora 13 live dvd &nbsp;so I could gather in-line =
function&nbsp;probing of the OOM code path when testing in a disk-less =
environment to confirm if the OOM killer was =
invoked.</div><div><br></div><div>I also logged some memory statistics. =
If anyone is interested I&nbsp;have attached the debug files and logs to =
<a href=3D"http://kernel.org">kernel.org</a> bug:</div><div><a =
href=3D"https://bugzilla.kernel.org/show_bug.cgi?id=3D20792">https://bugzi=
lla.kernel.org/show_bug.cgi?id=3D20792</a></div><div><br></div><div>------=
-----------------------</div><div>Testing: _with_ a =
disk</div><div>-----------------------------</div><div><br></div><div>A =
ran the c program from&nbsp;</div><div><a =
href=3D"http://linuxdevcenter.com/pub/a/linux/2006/11/30/linux-out-of-memo=
ry.html">http://linuxdevcenter.com/pub/a/linux/2006/11/30/linux-out-of-mem=
ory.html</a></div><div>with the addition to print out mallinfo and =
/proc/meminfo statistics.</div><div><br></div><div>The objective of the =
mem-pressure.c is to allocate huge blocks and fill them with&nbsp;1s =
until the OOM killer is invoked and kills of offending process to rescue =
the&nbsp;system from memory pressure.</div><div><br></div><div>The test =
program successfully created memory pressure on the Fedora 13 =
system&nbsp;and caused the OOM killer to kill off offending process =
according to their&nbsp;calculated "badness" score. &nbsp;In my test =
runs if mem-pressure wasn't killed directly&nbsp;then gnome, metacity, =
or the shell were killed which in turn killed =
mem-pressure.</div><div><br></div><div>The SystemTap script, oom.stp, =
shows the system going through the code sequence&nbsp;leading up to the =
OOM killer:</div><div>|&gt; =
__alloc_pages_may_oom()</div><div>&nbsp;&nbsp; &nbsp; &nbsp; &nbsp;|&gt; =
out_of_memory()</div><div>&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp;|&gt; oom_kill_process()</div><div>&nbsp;&nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;|&gt;oom_kill_task()</div><div>&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp;|&gt;__oom_kill_task()</div><div><br></div><div>[Note: I =
removed probing __alloc_pages_slowpath() from oom.stp =
disk-environment&nbsp;testing to make the oom-stp.out log a little =
simpler to read.]</div><div><br></div><div>=3D=3D=3DAnalysis=3D=3D=3D</div=
><div>No surprises here. &nbsp;With an attached disk the OOM killer was =
able to be invoked&nbsp;and relive the memory pressure returning the =
system to a ~functioning state. &nbsp;With the oom.stp script we can see =
the system following the code path to invoke&nbsp;the OOM =
killer.&nbsp;</div><div><br></div><div>[Note in some of my test runs I =
noticed some other services were killed before&nbsp;mem-pressure leading =
to a somewhat crippled system, but the main point is the&nbsp;system did =
_not_ hang.]</div><div><br></div><div>-Test data-</div><div>See the =
oom-test-data.tar.gz: OOM_testing/disk for test results using =
a&nbsp;disk environment. &nbsp;OOM_testing/test/code has the scripts, =
and test program.&nbsp;I compiled the c program as mem-pressure, and =
logged the output to&nbsp;mem-pressure.out. In this sequence of testing =
I did not adjust any oom_adj&nbsp;values. &nbsp;I also collected various =
memory statistics every second using the&nbsp;meminfo.sh script, and =
logged the output to meminfo.out. meminfo.out shows =
the</div><div>system's memory resources being used, and mem-pressure.out =
shows the&nbsp;consumption of memory resources by the mem-pressure =
program. The SystemTap&nbsp;script, oom.stp, output was logged to =
oom-stp.out</div><div><br></div><div>-----------------------------</div><d=
iv>Testing: _NO_ a disk (disk-less =
environment)</div><div>-----------------------------</div><div><br></div><=
div>I booted the Fedora 13 live dvd with SystemTap and kernel debuginfo =
rpms added&nbsp;to ensure a disk-less =
environment.</div><div><br></div><div>-Additions to the test program and =
scripts-</div><div>I ran the same mem-pressure from testing with a disk, =
but I added code to set&nbsp;the oom_adj value of mem-pressure to 15 to =
ensure if the OOM killer was invoked&nbsp;it would first kill the =
mem-pressure program.</div><div><br></div><div>I also added =
&nbsp;__alloc_pages_slowpath() function to the oom.stp SystemTap =
script&nbsp;to show more of the memory allocation code path leading up =
to OOM killer.</div><div><br></div><div>The test program mem-pressure =
still successfully creates memory pressure, and&nbsp;as in previous =
testing the system hard hangs when system memory resources =
have&nbsp;been =
exhausted.</div><div><br></div><div>=3D=3D=3DAnalysis=3D=3D=3D</div><div>T=
he system hard hangs after memory resources have been exhausted =
&nbsp;by&nbsp;mem-pressure. &nbsp;Probing the code =
path:</div><div>__alloc_pages_slowpath()</div><div>&nbsp;&nbsp; &nbsp; =
&nbsp; &nbsp;|&gt; __alloc_pages_may_oom()</div><div>&nbsp;&nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;|&gt; =
out_of_memory()</div><div>&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;|&gt; oom_kill_process() =
oom_kill_process</div><div>&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;|&gt;oom_kill_task</div><div>&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;|&gt;__oom_kill_task</div><div><br></div><div>I see the system =
accessing alloc_pages_slowpath(), however I never see the&nbsp;system =
enter into out_of_memory(), and thus __oom_kill_task is not invoked =
to&nbsp;kill the mem-pressure processes. Consequently the system is =
unable to relive&nbsp;the memory pressure, and the system hard =
hangs.</div><div><br></div><div>-Test Data-</div><div>See the =
oom-test-data.tar.gz: &nbsp;OOM_testing/NO_disk for test results =
using&nbsp;a disk-less environment. &nbsp;OOM_testing/test/code has the =
scripts, test program,&nbsp;and kickstart =
files.</div><div><br></div><div>The same test data was collected as in =
the disk-enviroment. &nbsp;I also added the&nbsp;kickstart files I used =
to make the Fedora 13 SystemTap Debug live dvd. &nbsp;If =
your&nbsp;interested the instructions to create a Fedora Live CD are =
at:</div><div><a =
href=3D"http://fedoraproject.org/wiki/How_to_create_and_use_a_Live_CD">htt=
p://fedoraproject.org/wiki/How_to_create_and_use_a_Live_CD</a></div><div>W=
ith the kickstarts provided one would run:</div><div>&nbsp;&nbsp; &nbsp; =
&nbsp; &nbsp;livecd-creator \</div><div>&nbsp;&nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;--config=3D/path/to/kickstartsfedora-livecd-desktop.ks =
\</div><div>&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;--fslabel=3DFedora-LiveCD-Debug =
--cache=3D/var/cache/live</div><div><br></div><div>(Note: I logged =
output to a mounted USB 2.0 flash =
drive.)</div><div><br></div><div>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</=
div><div><br></div><div>In summary, the test results show the OOM Killer =
not being invoked in the&nbsp;disk-less environment to relive memory =
pressure causing the system to hard&nbsp;hang. This may very well be a =
by-product of running a diskless environment and&nbsp;overcommitting =
memory resources. &nbsp;</div><div><br></div><div>Any insights into this =
issue are =
welcomed.</div><div>-Thanks</div><div><br></div><div>--</div><div>
<span class=3D"Apple-style-span" style=3D"border-collapse: separate; =
color: rgb(0, 0, 0); font-family: Helvetica; font-style: normal; =
font-variant: normal; font-weight: normal; letter-spacing: normal; =
line-height: normal; orphans: 2; text-align: auto; text-indent: 0px; =
text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; =
-webkit-border-horizontal-spacing: 0px; -webkit-border-vertical-spacing: =
0px; -webkit-text-decorations-in-effect: none; -webkit-text-size-adjust: =
auto; -webkit-text-stroke-width: 0px; font-size: medium; "><span =
class=3D"Apple-style-span" style=3D"border-collapse: separate; color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant: normal; font-weight: normal; letter-spacing: =
normal; line-height: normal; orphans: 2; text-indent: 0px; =
text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; =
-webkit-border-horizontal-spacing: 0px; -webkit-border-vertical-spacing: =
0px; -webkit-text-decorations-in-effect: none; -webkit-text-size-adjust: =
auto; -webkit-text-stroke-width: 0px; "><div style=3D"word-wrap: =
break-word; -webkit-nbsp-mode: space; -webkit-line-break: =
after-white-space; "><div><div>Antonio Rosales</div><div>IBM Linux =
Technology Center</div></div></div></span></span>
</div>

<br></body></html>=

--Apple-Mail-1-495423215--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
