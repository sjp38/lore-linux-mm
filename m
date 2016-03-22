Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 586CB6B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 10:47:30 -0400 (EDT)
Received: by mail-io0-f181.google.com with SMTP id c63so66129331iof.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 07:47:30 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id x32si15208364ioi.18.2016.03.22.07.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 07:47:29 -0700 (PDT)
Received: by mail-ig0-x231.google.com with SMTP id nk17so95155275igb.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 07:47:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <56F14EEE.7060308@huawei.com>
References: <56F14EEE.7060308@huawei.com>
Date: Tue, 22 Mar 2016 07:47:29 -0700
Message-ID: <CALvZod5PnHz5OsNrcfsMZ6=cxLBy9436htbKerv67S+CigwGbQ@mail.gmail.com>
Subject: Re: [RFC] mm: why cat /proc/pid/smaps | grep Rss is different from
 cat /proc/pid/statm?
From: Shakeel Butt <shakeelb@google.com>
Content-Type: multipart/alternative; boundary=047d7b10cdafe1f98f052ea44ade
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

--047d7b10cdafe1f98f052ea44ade
Content-Type: text/plain; charset=UTF-8

On Tue, Mar 22, 2016 at 6:55 AM, Xishi Qiu <qiuxishi@huawei.com> wrote:

> [root@localhost c_test]# cat /proc/3948/smaps | grep Rss
>
The /proc/[pid]/smaps read triggers the traversal of all of process's vmas
and then page tables and accumulate RSS on each present page table entry.

[root@localhost c_test]# cat /proc/3948/statm
> 1042 173 154 1 0 48 0
>
The files /proc/[pid]/statm and /proc/[pid]/status uses the counters
(MM_ANONPAGES & MM_FILEPAGES) in mm_struct to report RSS of a process.
These counters are modified on page table modifications. However the kernel
implements an optimization where each thread keeps a local copy of these
counters in its task_struct. These local counter are accumulated in the
shared counter of mm_struct after some number of page faults (I think 32)
faced by the thread and thus there will be mismatch with smaps file.

Shakeel

--047d7b10cdafe1f98f052ea44ade
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
On Tue, Mar 22, 2016 at 6:55 AM, Xishi Qiu <span dir=3D"ltr">&lt;<a href=3D=
"mailto:qiuxishi@huawei.com" target=3D"_blank">qiuxishi@huawei.com</a>&gt;<=
/span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px =
0px 0.8ex;border-left-width:1px;border-left-color:rgb(204,204,204);border-l=
eft-style:solid;padding-left:1ex">[root@localhost c_test]# cat /proc/3948/s=
maps | grep Rss<br></blockquote><div>The /proc/[pid]/smaps read triggers th=
e traversal of all of process&#39;s vmas and then page tables and accumulat=
e RSS on each present page table entry.</div><div><br></div><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left-width:1px;=
border-left-color:rgb(204,204,204);border-left-style:solid;padding-left:1ex=
">
[root@localhost c_test]# cat /proc/3948/statm<br>
1042 173 154 1 0 48 0<br></blockquote><div><span style=3D"font-family:Arial=
,Helvetica,sans-serif;font-size:13px;line-height:18px">The files /proc/[pid=
]/statm and /proc/[pid]/status uses the counters (MM_ANONPAGES &amp; MM_FIL=
EPAGES) in mm_struct to report RSS of a process. These counters are modifie=
d on page table modifications. However the kernel implements an optimizatio=
n where each thread keeps a local copy of these counters in its task_struct=
. These local counter are accumulated in the shared counter of mm_struct af=
ter some number of page faults (I think 32) faced by the thread and thus th=
ere will be mismatch with smaps file.<br></span></div><div><span style=3D"f=
ont-family:Arial,Helvetica,sans-serif;font-size:13px;line-height:18px"><br>=
</span></div><div><span style=3D"font-family:Arial,Helvetica,sans-serif;fon=
t-size:13px;line-height:18px">Shakeel</span></div></div></div></div>

--047d7b10cdafe1f98f052ea44ade--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
