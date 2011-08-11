Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 610FC6B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 08:48:01 -0400 (EDT)
Received: by wyi11 with SMTP id 11so1886837wyi.14
        for <linux-mm@kvack.org>; Thu, 11 Aug 2011 05:47:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1313049724.11241.YahooMailNeo@web111704.mail.gq1.yahoo.com>
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com>
 <1db776d865939be598cdb80054cf5d93.squirrel@xenotime.net> <1312874259.89770.YahooMailNeo@web111704.mail.gq1.yahoo.com>
 <alpine.DEB.2.00.1108090900170.30199@chino.kir.corp.google.com>
 <1312964098.7449.YahooMailNeo@web111712.mail.gq1.yahoo.com>
 <alpine.DEB.2.00.1108102106410.14230@chino.kir.corp.google.com>
 <1313046422.18195.YahooMailNeo@web111711.mail.gq1.yahoo.com>
 <alpine.DEB.2.00.1108110010220.23622@chino.kir.corp.google.com> <1313049724.11241.YahooMailNeo@web111704.mail.gq1.yahoo.com>
From: Denys Vlasenko <vda.linux@googlemail.com>
Date: Thu, 11 Aug 2011 14:47:37 +0200
Message-ID: <CAK1hOcN7q=F=UV=aCAsVOYO=Ex34X0tbwLHv9BkYkA=ik7G13w@mail.gmail.com>
Subject: Re: running of out memory => kernel crash
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: David Rientjes <rientjes@google.com>, Randy Dunlap <rdunlap@xenotime.net>, "\"\"\"linux-kernel@vger.kernel.org\"\"\"" <linux-kernel@vger.kernel.org>, "\"\"linux-mm@kvack.org\"\"" <linux-mm@kvack.org>

On Thu, Aug 11, 2011 at 10:02 AM, Mahmood Naderan <nt_mahmood@yahoo.com> wr=
ote:
>>Despite it's name, kswapd is still active, it's trying to reclaim memory
>>to prevent having to kill a process as the last resort.
>
> I understand what you said, but I did two scenarios:
> 1- I wrote a simple C++ program that "new" a lot of pointers.
> =A0=A0 for ( int i =3D 0; i < n; i++ ) {
> =A0=A0=A0=A0 for ( int j =3D 0; j < n; j++ ) {
> =A0=A0=A0=A0=A0=A0 for ( int k =3D 0; k < n; k++ ) {
> =A0=A0=A0=A0=A0=A0=A0=A0 for ( int l =3D 0; l < n; l++ ) {
> =A0=A0=A0 =A0 =A0 =A0=A0 double *ptr1 =3D new double[n*i];
> =A0=A0=A0 =A0 =A0 =A0=A0 double *ptr2 =3D new double[n*j];
> =A0=A0=A0=A0 }}}}
>
> When I run the program, it ill eat the memory and when it reaches the
> maximum ram, it get killed and I saw=A0 message on terminal:
>
> mahmood@vpc:~$ ./leak
> Killed
>
> for this scenario, there is no kswapd process running.

Why do you think kswapd should get active? What it can possibly do
if there is no swap and therefore it can't free memory by writing
out RAM pages to swap?

> 2- There is 300MB ram. I opened an application saw that
> free space reduced to 100MB, then another application reduced the free
> space to 30MB. Another application reduced to 4MB. Now the "kswapd"
> is running with a lot of disk activity and tries to keep free space at 4M=
B.
> In this scenario, No application is killed.
>
> The question is why in one scenario, the application is killed and in one
> scenario, kswapd is running.

In scenario 2, the disk activity comes from constant paging in (reading)
of pages which contain code of running binaries.

Since machine has no free RAM and no swap at all, when it needs
a free page it can't swap out a dirty (modified) page or anon
(usually malloced space) page. Thus the only option is to find some
not recently used page with read-only, file-backed content (usually some
binary's text page, but can be any read-only file mapping) and reuse it.

If there are no really old, unused read-only, file-backed pages,
then the discarded page will be needed soon, will need to be read from disk=
,
and will evict another similar page. Which will be needed soon too,
will need to be read from disk, and will evict another such page...
ad infinitum.

--=20
vda

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
