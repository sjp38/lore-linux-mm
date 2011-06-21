Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3D57F6B013B
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 12:02:08 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p5LG23WD030586
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:02:04 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by kpbe11.cbf.corp.google.com with ESMTP id p5LG1BLw021982
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:02:02 -0700
Received: by qyk10 with SMTP id 10so2387522qyk.11
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:01:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E00AFE6.20302@5t9.de>
References: <4E00AFE6.20302@5t9.de>
Date: Tue, 21 Jun 2011 09:01:58 -0700
Message-ID: <BANLkTime3JN9-fAi3Lwx7UdXQo41eQh0iw@mail.gmail.com>
Subject: Re: "make -j" with memory.(memsw.)limit_in_bytes smaller than
 required -> livelock, even for unlimited processes
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lutz Vieweg <lvml@5t9.de>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, Jun 21, 2011 at 7:51 AM, Lutz Vieweg <lvml@5t9.de> wrote:
> Dear Memory Ressource Controller maintainers,
>
> by using per-user control groups with a limit on memory (and swap) I am
> trying to secure a shared development server against memory exhaustion
> by any one single user - as it happened before when somebody imprudently
> issued "make -j" (which has the infamous habit to spawn an unlimited
> number of processes) on a large software project with many source files.
>
> The memory limitation using control groups works just fine when
> only a few processes sum up to a usage that exceeds the limits - the
> processes are OOM-killed, then, and the others users are unaffected.
>
> But the original cause, a "make -j" on many source files, leads to
> the following ugly symptom:
>
> - make starts numerous (~ 100 < x < 200) gcc processes
>
> - some of those gcc processes get OOM-killed quickly, then
> =A0a few more are killed, but with increasing pauses in between
>
> - then after a few seconds, no more gcc processes are killed, but
> =A0the "make" process and its childs do not show any progress anymore
>
> - at this time, top indicates 100% "system" CPU usage, mostly by
> =A0"[kworker/*]" threads (one per CPU). But processes from other
> =A0users, that only require CPU, proceed to run.

The following patch might not be the root-cause of livelock, but
should reduce the [kworker/*] in your case.

=3D=3D
