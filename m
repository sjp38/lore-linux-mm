Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9B06D6B016E
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 04:02:06 -0400 (EDT)
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com> <1db776d865939be598cdb80054cf5d93.squirrel@xenotime.net> <1312874259.89770.YahooMailNeo@web111704.mail.gq1.yahoo.com> <alpine.DEB.2.00.1108090900170.30199@chino.kir.corp.google.com> <1312964098.7449.YahooMailNeo@web111712.mail.gq1.yahoo.com> <alpine.DEB.2.00.1108102106410.14230@chino.kir.corp.google.com> <1313046422.18195.YahooMailNeo@web111711.mail.gq1.yahoo.com> <alpine.DEB.2.00.1108110010220.23622@chino.kir.corp.google.com>
Message-ID: <1313049724.11241.YahooMailNeo@web111704.mail.gq1.yahoo.com>
Date: Thu, 11 Aug 2011 01:02:04 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: running of out memory => kernel crash
In-Reply-To: <alpine.DEB.2.00.1108110010220.23622@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, "\"\"\"linux-kernel@vger.kernel.org\"\"\"" <linux-kernel@vger.kernel.org>, "\"\"linux-mm@kvack.org\"\"" <linux-mm@kvack.org>

>Despite it's name, kswapd is still active, it's trying to reclaim memory =
=0A>to prevent having to kill a process as the last resort.=0A=A0=0AI under=
stand what you said, but I did two scenarios:=0A1- I wrote a simple C++ pro=
gram that "new" a lot of pointers.=0A=A0=A0 for ( int i =3D 0; i < n; i++ )=
 {=0A=A0=A0=A0=A0 for ( int j =3D 0; j < n; j++ ) {=0A=A0=A0=A0=A0=A0=A0 fo=
r ( int k =3D 0; k < n; k++ ) {=0A=A0=A0=A0=A0=A0=A0=A0=A0 for ( int l =3D =
0; l < n; l++ ) {=0A=A0=A0=A0 =A0 =A0 =A0=A0 double *ptr1 =3D new double[n*=
i];=0A=A0=A0=A0 =A0 =A0 =A0=A0 double *ptr2 =3D new double[n*j];=0A=A0=A0=
=A0=A0 }}}}=0A=0AWhen I run the program, it ill eat the memory and when it =
reaches the=0Amaximum ram, it get killed and I saw=A0 message on terminal:=
=0A=0Amahmood@vpc:~$ ./leak=0AKilled=0A=0Afor this scenario, there is no ks=
wapd process running. As it eats the memory=0Asuddenly it get killed.=0A=0A=
2- There is 300MB ram. I opened an application saw that=0Afree space reduce=
d to 100MB, then another application reduced the free=0Aspace to 30MB. Anot=
her application reduced to 4MB. Now the "kswapd"=0Ais running with a lot of=
 disk activity and tries to keep free space at 4MB.=0AIn this scenario, No =
application is killed.=0A=0AThe question is why in one scenario, the applic=
ation is killed and in one=0Ascenario, kswapd is running.=0A=0AI think in t=
he first scenario, the oom_score is calculated more rapidly =0Athan the sec=
ond, so immediately is get killed. So kswapd has no chance =0Ato run becaus=
e application is killed sooner. In the second scenario, =0Akswapd has time =
to run first. So it will try to free some spaces. However =0Asince the disk=
 activity is very high, the response time is very high=0Aso the oom_score i=
s calculated lately than first scenario.=0A=0AIs my understandings correct?=
=0A=0A=0A>If /proc/sys/vm/panic_on_oom is not set, as previously mentioned,=
 then =0A>we'll need the kernel log to diagnose this further.=0AI checked t=
hat and it is 0. I am trying to reproduce the problem to get some logs=0A=
=0A=0A// Naderan *Mahmood;=0A=0A=0A----- Original Message -----=0AFrom: Dav=
id Rientjes <rientjes@google.com>=0ATo: Mahmood Naderan <nt_mahmood@yahoo.c=
om>=0ACc: Randy Dunlap <rdunlap@xenotime.net>; """linux-kernel@vger.kernel.=
org""" <linux-kernel@vger.kernel.org>; ""linux-mm@kvack.org"" <linux-mm@kva=
ck.org>=0ASent: Thursday, August 11, 2011 11:43 AM=0ASubject: Re: running o=
f out memory =3D> kernel crash=0A=0AOn Thu, 11 Aug 2011, Mahmood Naderan wr=
ote:=0A=0A> >The default behavior is to kill all eligible and unkillable th=
reads until =0A> >there are none left to sacrifice (i.e. all kthreads and O=
OM_DISABLE).=0A> =A0=0A> In a simple test with virtualbox, I reduced the am=
ount of ram to 300MB. =0A> Then I ran "swapoff -a" and opened some applicat=
ions. I noticed that the free=0A> spaces is kept around 2-3MB and "kswapd" =
is running. Also I saw that disk=0A> activity was very high. =0A> That mean=
 although "swap" partition is turned off, "kswapd" was trying to do=0A> som=
ething. I wonder how that behavior can be explained?=0A> =0A=0ADespite it's=
 name, kswapd is still active, it's trying to reclaim memory =0Ato prevent =
having to kill a process as the last resort.=0A=0AIf /proc/sys/vm/panic_on_=
oom is not set, as previously mentioned, then =0Awe'll need the kernel log =
to diagnose this further.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
