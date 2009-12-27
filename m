Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8FD2860021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 13:37:59 -0500 (EST)
Received: by ywh5 with SMTP id 5so13497745ywh.11
        for <linux-mm@kvack.org>; Sun, 27 Dec 2009 10:37:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091227124732.GA3601@balbir.in.ibm.com>
References: <cover.1261858972.git.kirill@shutemov.name>
	 <20091227124732.GA3601@balbir.in.ibm.com>
Date: Sun, 27 Dec 2009 20:37:57 +0200
Message-ID: <cc557aab0912271037scb29fe1xcebe9adfaea97b24@mail.gmail.com>
Subject: Re: [PATCH v4 0/4] cgroup notifications API and memory thresholds
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: multipart/mixed; boundary=0050450170486e6345047bba16b3
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--0050450170486e6345047bba16b3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Sun, Dec 27, 2009 at 2:47 PM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> * Kirill A. Shutemov <kirill@shutemov.name> [2009-12-27 04:08:58]:
>
>> This patchset introduces eventfd-based API for notifications in cgroups =
and
>> implements memory notifications on top of it.
>>
>> It uses statistics in memory controler to track memory usage.
>>
>> Output of time(1) on building kernel on tmpfs:
>>
>> Root cgroup before changes:
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0506.37 user 60.93s system 193% cpu 4=
:52.77 total
>> Non-root cgroup before changes:
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.14 user 62.66s system 193% cpu 4=
:54.74 total
>> Root cgroup after changes (0 thresholds):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.13 user 62.20s system 193% cpu 4=
:53.55 total
>> Non-root cgroup after changes (0 thresholds):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.70 user 64.20s system 193% cpu 4=
:55.70 total
>> Root cgroup after changes (1 thresholds, never crossed):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0506.97 user 62.20s system 193% cpu 4=
:53.90 total
>> Non-root cgroup after changes (1 thresholds, never crossed):
>> =C2=A0 =C2=A0 =C2=A0 make -j2 =C2=A0507.55 user 64.08s system 193% cpu 4=
:55.63 total
>>
>> Any comments?
>
> Thanks for adding the documentation, now on to more critical questions
>
> 1. Any reasons for not using cgroupstats?

Could you explain the idea? I don't see how cgroupstats applicable for
the task.

> 2. Is there a user space test application to test this code.

Attached. It's not very clean, but good enough for testing propose.
Example of usage:

$ echo '/cgroups/memory.usage_in_bytes 1G' | ./cgroup_event_monitor

> =C2=A0IIUC,
> I need to write a program that uses eventfd(2) and then passes
> the eventfd descriptor and thresold to cgroup.*event* file and
> then the program will get notified when the threshold is reached?

You need to pass eventfd descriptor, descriptor of control file to be
monitored (memory.usage_in_bytes or memory.memsw.usage_in_bytes) and
threshold.

Do you want to rename cgroup.event_control to cgroup.event?

--0050450170486e6345047bba16b3
Content-Type: application/octet-stream; name="cgroup_event_monitor.c"
Content-Disposition: attachment; filename="cgroup_event_monitor.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g3q5oq4k0

I2RlZmluZSBfR05VX1NPVVJDRQoKI2luY2x1ZGUgPGFzc2VydC5oPgojaW5jbHVkZSA8ZXJybm8u
aD4KI2luY2x1ZGUgPGZjbnRsLmg+CiNpbmNsdWRlIDxsaWJnZW4uaD4KI2luY2x1ZGUgPGxpbWl0
cy5oPgojaW5jbHVkZSA8cG9sbC5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN0ZGxp
Yi5oPgojaW5jbHVkZSA8c3RyaW5nLmg+CiNpbmNsdWRlIDx1bmlzdGQuaD4KI2luY2x1ZGUgPHN5
cy9ldmVudGZkLmg+CgojZGVmaW5lIE1BWF9FRkQgMTAwCgpzdHJ1Y3QgZXZlbnQgewoJY2hhciAq
cGF0aDsKCWNoYXIgKmFyZ3M7Cn07CgppbnQgbWFpbihpbnQgYXJnYywgY2hhciAqKmFyZ3YpCnsK
CXN0cnVjdCBldmVudCBldmVudHNbTUFYX0VGRF07CglzdHJ1Y3QgcG9sbGZkIHBvbGxmZHNbTUFY
X0VGRF07CglpbnQgbiA9IDA7CgljaGFyIGxpbmVbUEFUSF9NQVhdOwoJaW50IHJldDsKCgl3aGls
ZSAoZmdldHMobGluZSwgUEFUSF9NQVgsIHN0ZGluKSkgewoJCWludCBldmVudF9jb250cm9sLCBj
ZmQ7CgkJY2hhciAqYXJncyA9IHN0cmNocm51bChsaW5lLCAnICcpOwoKCQlpZiAobiA+PSBNQVhf
RUZEKSB7CgkJCWZwcmludGYoc3RkZXJyLCAiVG9vIG1hbnkgZXZlbnRzIHJlZ2lzdGVyZWRcbiIp
OwoJCX0KCgkJaWYgKCphcmdzKQoJCQkqYXJncysrID0gJ1wwJzsKCgkJZXZlbnRzW25dLnBhdGgg
PSBtYWxsb2Moc3RybGVuKGxpbmUpICsgMSk7CgkJYXNzZXJ0KGV2ZW50c1tuXS5wYXRoKTsKCQlz
dHJjcHkoZXZlbnRzW25dLnBhdGgsIGxpbmUpOwoKCQlhcmdzW3N0cmxlbihhcmdzKSAtIDFdID0g
J1wwJzsKCQlldmVudHNbbl0uYXJncyA9IG1hbGxvYyhzdHJsZW4oYXJncykgKyAxKTsKCQlhc3Nl
cnQoZXZlbnRzW25dLmFyZ3MpOwoJCXN0cmNweShldmVudHNbbl0uYXJncywgYXJncyk7CgoJCWNm
ZCA9IG9wZW4oZXZlbnRzW25dLnBhdGgsIE9fUkRPTkxZKTsKCQlpZiAoY2ZkIDwgMCkgewoJCQlm
cHJpbnRmKHN0ZGVyciwgIkNhbm5vdCBvcGVuICVzOiAlc1xuIiwgZXZlbnRzW25dLnBhdGgsCgkJ
CQkJc3RyZXJyb3IoZXJybm8pKTsKCQkJcmV0dXJuIDE7CgkJfQoKCQlwb2xsZmRzW25dLmV2ZW50
cyA9IFBPTExJTjsKCQlwb2xsZmRzW25dLmZkID0gZXZlbnRmZCgwLCAwKTsKCgkJZGlybmFtZShs
aW5lKTsKCQlzdHJjYXQobGluZSwgIi9jZ3JvdXAuZXZlbnRfY29udHJvbCIpOwoKCQlldmVudF9j
b250cm9sID0gb3BlbihsaW5lLCBPX1dST05MWSk7CgkJaWYgKGV2ZW50X2NvbnRyb2wgPCAwKSB7
CgkJCWZwcmludGYoc3RkZXJyLCAiQ2Fubm90IG9wZW4gJXM6ICVzXG4iLCBsaW5lLAoJCQkJCXN0
cmVycm9yKGVycm5vKSk7CgkJCXJldHVybiAxOwoJCX0KCgkJc25wcmludGYobGluZSwgUEFUSF9N
QVgsICIlZCAlZCAlc1xuIiwgcG9sbGZkc1tuXS5mZCwgY2ZkLAoJCQkJZXZlbnRzW25dLmFyZ3Mp
OwoKCQlpZiAod3JpdGUoZXZlbnRfY29udHJvbCwgbGluZSwgc3RybGVuKGxpbmUpKSA8IDApIHsK
CQkJZnByaW50ZihzdGRlcnIsICJDYW5ub3Qgd3JpdGUgdG8gY2dyb3VwLmV2ZW50X2NvbnRyb2w6
ICVzXG4iLAoJCQkJCXN0cmVycm9yKGVycm5vKSk7CgkJCXJldHVybiAxOwoJCX0KCgkJY2xvc2Uo
ZXZlbnRfY29udHJvbCk7CgkJY2xvc2UoY2ZkKTsKCgkJbisrOwoJfQoKCXdoaWxlKChyZXQgPSBw
b2xsKHBvbGxmZHMsIG4sIC0xKSkgIT0gMCkgewoJCWludCBpOwoKCQlpZiAocmV0IDwgMCkgewoJ
CQlwZXJyb3IoInBvbGwoKSIpOwoJCQlyZXR1cm4gMTsKCQl9CgoJCWZvcihpPTA7IChpIDwgbikg
JiYgcmV0OyBpKyspIHsKCQkJaWYgKHBvbGxmZHNbaV0ucmV2ZW50cyAmIFBPTExJTikgewoJCQkJ
cHJpbnRmKCIlcyAlc1xuIiwgZXZlbnRzW2ldLnBhdGgsCgkJCQkJCWV2ZW50c1tpXS5hcmdzKTsK
CQkJCWlmIChyZWFkKHBvbGxmZHNbaV0uZmQsIGxpbmUsIDgpIDwgMCkgewoJCQkJCXBlcnJvcigi
cmVhZCgpIik7CgkJCQkJcmV0dXJuIDE7CgkJCQl9CgkJCQlyZXQtLTsKCQkJfQoKCQkJaWYgKHBv
bGxmZHNbaV0ucmV2ZW50cyAmIH4oUE9MTElOKSkgewoJCQkJcHJpbnRmKCIlcyglcyk6IHVuZXhw
ZWN0ZWQgZXZlbnQ6ICUwOHhcbiIsCgkJCQkJCWV2ZW50c1tpXS5wYXRoLAoJCQkJCQlldmVudHNb
aV0uYXJncywKCQkJCQkJcG9sbGZkc1tpXS5yZXZlbnRzKTsKCQkJCXJldHVybiAxOwoJCQl9CgkJ
fQoJfQoKCXJldHVybiAwOwp9Cg==
--0050450170486e6345047bba16b3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
