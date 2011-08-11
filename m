Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 458E26B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 11:13:49 -0400 (EDT)
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com> <1db776d865939be598cdb80054cf5d93.squirrel@xenotime.net> <1312874259.89770.YahooMailNeo@web111704.mail.gq1.yahoo.com> <alpine.DEB.2.00.1108090900170.30199@chino.kir.corp.google.com> <1312964098.7449.YahooMailNeo@web111712.mail.gq1.yahoo.com> <alpine.DEB.2.00.1108102106410.14230@chino.kir.corp.google.com> <1313046422.18195.YahooMailNeo@web111711.mail.gq1.yahoo.com> <alpine.DEB.2.00.1108110010220.23622@chino.kir.corp.google.com> <1313049724.11241.YahooMailNeo@web111704.mail.gq1.yahoo.com> <CAK1hOcN7q=F=UV=aCAsVOYO=Ex34X0tbwLHv9BkYkA=ik7G13w@mail.gmail.com>
Message-ID: <1313075625.50520.YahooMailNeo@web111715.mail.gq1.yahoo.com>
Date: Thu, 11 Aug 2011 08:13:45 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: running of out memory => kernel crash
In-Reply-To: <CAK1hOcN7q=F=UV=aCAsVOYO=Ex34X0tbwLHv9BkYkA=ik7G13w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <vda.linux@googlemail.com>
Cc: David Rientjes <rientjes@google.com>, Randy Dunlap <rdunlap@xenotime.net>, "\"linux-kernel@vger.kernel.org\"" <linux-kernel@vger.kernel.org>, "\"linux-mm@kvack.org\"" <linux-mm@kvack.org>

>What it can possibly do if there is no swap and therefore it =0A=0A>can't =
free memory by writing out RAM pages to swap?=0A=0A=0A>the disk activity co=
mes from constant paging in (reading)=0A>of pages which contain code of run=
ning binaries.=0A=0AWhy the disk activity does not appear in the first scen=
ario?=0A=0A=0A>Thus the only option is to find some not recently used page=
=0A> with read-only, file-backed content (usually some binary's =0A=0A>text=
 page, but can be any read-only file mapping) and reuse it.=0AWhy "killing"=
 does not appear here? Why it try to "find some =0A=0Arecently used page"?=
=0A=0A=0ABoth scenarios have one common thing... Running out of memory.=0AB=
ut they behave differently.=0A=0A=0A// Naderan *Mahmood;=0A=0A=0A__________=
______________________=0AFrom: Denys Vlasenko <vda.linux@googlemail.com>=0A=
To: Mahmood Naderan <nt_mahmood@yahoo.com>=0ACc: David Rientjes <rientjes@g=
oogle.com>; Randy Dunlap <rdunlap@xenotime.net>; """"linux-kernel@vger.kern=
el.org"""" <linux-kernel@vger.kernel.org>; """linux-mm@kvack.org""" <linux-=
mm@kvack.org>=0ASent: Thursday, August 11, 2011 5:17 PM=0ASubject: Re: runn=
ing of out memory =3D> kernel crash=0A=0AOn Thu, Aug 11, 2011 at 10:02 AM, =
Mahmood Naderan <nt_mahmood@yahoo.com> wrote:=0A>>Despite it's name, kswapd=
 is still active, it's trying to reclaim memory=0A>>to prevent having to ki=
ll a process as the last resort.=0A>=0A> I understand what you said, but I =
did two scenarios:=0A> 1- I wrote a simple C++ program that "new" a lot of =
pointers.=0A> =A0=A0 for ( int i =3D 0; i < n; i++ ) {=0A> =A0=A0=A0=A0 for=
 ( int j =3D 0; j < n; j++ ) {=0A> =A0=A0=A0=A0=A0=A0 for ( int k =3D 0; k =
< n; k++ ) {=0A> =A0=A0=A0=A0=A0=A0=A0=A0 for ( int l =3D 0; l < n; l++ ) {=
=0A> =A0=A0=A0 =A0 =A0 =A0=A0 double *ptr1 =3D new double[n*i];=0A> =A0=A0=
=A0 =A0 =A0 =A0=A0 double *ptr2 =3D new double[n*j];=0A> =A0=A0=A0=A0 }}}}=
=0A>=0A> When I run the program, it ill eat the memory and when it reaches =
the=0A> maximum ram, it get killed and I saw=A0 message on terminal:=0A>=0A=
> mahmood@vpc:~$ ./leak=0A> Killed=0A>=0A> for this scenario, there is no k=
swapd process running.=0A=0AWhy do you think kswapd should get active? What=
 it can possibly do=0Aif there is no swap and therefore it can't free memor=
y by writing=0Aout RAM pages to swap?=0A=0A> 2- There is 300MB ram. I opene=
d an application saw that=0A> free space reduced to 100MB, then another app=
lication reduced the free=0A> space to 30MB. Another application reduced to=
 4MB. Now the "kswapd"=0A> is running with a lot of disk activity and tries=
 to keep free space at 4MB.=0A> In this scenario, No application is killed.=
=0A>=0A> The question is why in one scenario, the application is killed and=
 in one=0A> scenario, kswapd is running.=0A=0AIn scenario 2, the disk activ=
ity comes from constant paging in (reading)=0Aof pages which contain code o=
f running binaries.=0A=0ASince machine has no free RAM and no swap at all, =
when it needs=0Aa free page it can't swap out a dirty (modified) page or an=
on=0A(usually malloced space) page. Thus the only option is to find some=0A=
not recently used page with read-only, file-backed content (usually some=0A=
binary's text page, but can be any read-only file mapping) and reuse it.=0A=
=0AIf there are no really old, unused read-only, file-backed pages,=0Athen =
the discarded page will be needed soon, will need to be read from disk,=0Aa=
nd will evict another similar page. Which will be needed soon too,=0Awill n=
eed to be read from disk, and will evict another such page...=0Aad infinitu=
m.=0A=0A-- =0Avda=A0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
