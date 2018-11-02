Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 681AB6B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 00:38:30 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id k14-v6so665250pls.21
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 21:38:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x17-v6si31936809pgl.414.2018.11.01.21.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 21:38:28 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA24ZGQw124302
	for <linux-mm@kvack.org>; Fri, 2 Nov 2018 00:38:28 -0400
Received: from smtp.notes.na.collabserv.com (smtp.notes.na.collabserv.com [192.155.248.72])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ngbcrqu0f-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Nov 2018 00:38:28 -0400
Received: from localhost
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-mm@kvack.org> from <npiggin@au1.ibm.com>;
	Fri, 2 Nov 2018 04:38:27 -0000
Subject: Re: PIE binaries are no longer mapped below 4 GiB on ppc64le
In-Reply-To: <3da6549832ef68b93b210d5a32b3f12f3565cab0.camel@kernel.crashing.org>
From: "Nick Piggin" <npiggin@au1.ibm.com>
Date: Fri, 2 Nov 2018 04:38:20 +0000
MIME-Version: 1.0
References: <3da6549832ef68b93b210d5a32b3f12f3565cab0.camel@kernel.crashing.org>,<87k1lyf2x3.fsf@oldenburg.str.redhat.com>
 <20181031185032.679e170a@naga.suse.cz>
 <877ehyf1cj.fsf@oldenburg.str.redhat.com>
Message-Id: <OFD0143B4A.D4AA34CC-ON00258339.0016EFAF-00258339.00197B9C@notes.na.collabserv.com>
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org
Cc: anton@linux.ibm.com, fweimer@redhat.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, msuchanek@suse.de

<div class=3D"socmaildefaultfont" dir=3D"ltr" style=3D"font-family:Arial, H=
elvetica, sans-serif;font-size:10.5pt" ><blockquote data-history-content-mo=
dified=3D"1" dir=3D"ltr" style=3D"border-left:solid #aaaaaa 2px; margin-lef=
t:5px; padding-left:5px; direction:ltr; margin-right:0px" >----- Original m=
essage -----<br>From: Benjamin Herrenschmidt &lt;benh@kernel.crashing.org&g=
t;<br>To: Florian Weimer &lt;fweimer@redhat.com&gt;, "Michal Such=C3=A1nek"=
 &lt;msuchanek@suse.de&gt;<br>Cc: linux-mm@kvack.org, linuxppc-dev@lists.oz=
labs.org, Nick Piggin &lt;npiggin@au1.ibm.com&gt;, Anton Blanchard &lt;anto=
n@au1.ibm.com&gt;<br>Subject: Re: PIE binaries are no longer mapped below 4=
 GiB on ppc64le<br>Date: Thu, Nov 1, 2018 8:24 AM<br>&nbsp;
<div><font size=3D"2" face=3D"Default Monospace,Courier New,Courier,monospa=
ce" >On Wed, 2018-10-31 at 18:54 +0100, Florian Weimer wrote:<br>&gt;<br>&g=
t; It would matter to C code which returns the address of a global variable=
<br>&gt; in the main program through and (implicit) int return value.<br>&g=
t;<br>&gt; The old behavior hid some pointer truncation issues.<br><br>Hidi=
ng bugs like that is never a good idea..<br><br>&gt; &gt; Maybe it would be=
 good idea to generate 64bit relocations on 64bit<br>&gt; &gt; targets?<br>=
&gt;<br>&gt; Yes, the Go toolchain definitely needs fixing for PIE. &nbsp;I=
 don't dispute<br>&gt; that.<br><br>There was never any ABI guarantee that =
programs would be loaded below<br>4G... it just *happened*, so that's not p=
er-se an ABI change.<br><br>That said, I'm surprised of the choice of addre=
ss.. I would have rather<br>moved to above 1TB to benefit from 1T segments.=
..<br><br>Nick, Anton, do you know anything about that change ?</font></div=
></blockquote>
<div dir=3D"ltr" >Looks like Michael found the offending commit.</div>
<div dir=3D"ltr" >&nbsp;</div>
<div dir=3D"ltr" >I guess there is precedent for avoiding address space exp=
ansion as a compatibility concern, with the 128TB limit. That's pretty horr=
ible though. I would have much rather added some new limits or a new system=
 call even that could be used to control virtual address space allocation b=
ehaviour without all these ad hoc mmap flags and implicit changes to behavi=
our with different combinations of parameters to mmap(2). Anyway I digress.=
</div>
<div dir=3D"ltr" >&nbsp;</div>
<div dir=3D"ltr" >I was looking at the first 1T segments issue a while ago.=
 I *think* we might be able to use a 1T segment for address 0 by default, a=
nd then hit it with a hammer and go back to 256MB if the app does something=
 interesting like a fixed 4k mapping or hugetlbfs mapping.</div>
<div dir=3D"ltr" >&nbsp;</div>
<div dir=3D"ltr" >Thanks,</div>
<div dir=3D"ltr" >Nick</div>
<div dir=3D"ltr" >&nbsp;</div></div><BR>
