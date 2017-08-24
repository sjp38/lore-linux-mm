Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 270AE2808A4
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 10:20:08 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 185so3807581pgd.6
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 07:20:08 -0700 (PDT)
Received: from mail.crc.id.au (mail.crc.id.au. [2407:e400:b000:200::25])
        by mx.google.com with ESMTPS id h132si2913223pfe.209.2017.08.24.07.20.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 07:20:06 -0700 (PDT)
From: Steven Haigh <netwiz@crc.id.au>
Subject: Re: [Bug 196729] New: System becomes unresponsive when swapping - Regression since 4.10.x
Date: Fri, 25 Aug 2017 00:19:56 +1000
Message-ID: <3167565.Qac206UD3A@wopr.lan.crc.id.au>
In-Reply-To: <20170824124139.GJ5943@dhcp22.suse.cz>
References: <bug-196729-27@https.bugzilla.kernel.org/> <3069262.adKtTK0b29@wopr.lan.crc.id.au> <20170824124139.GJ5943@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart5469704.DWktjsOJT5"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org

--nextPart5469704.DWktjsOJT5
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="UTF-8"

On Thursday, 24 August 2017 10:41:39 PM AEST Michal Hocko wrote:
> On Thu 24-08-17 00:30:40, Steven Haigh wrote:
> > On Wednesday, 23 August 2017 11:38:48 PM AEST Michal Hocko wrote:
> > > On Tue 22-08-17 15:55:30, Andrew Morton wrote:
> > > > (switched to email.  Please respond via emailed reply-to-all, not v=
ia
> > > > the
> > > > bugzilla web interface).
> > > >=20
> > > > On Tue, 22 Aug 2017 11:17:08 +0000 bugzilla-daemon@bugzilla.kernel.=
org
> >=20
> > wrote:
> > > [...]
> > >=20
> > > > Sadly I haven't been able to capture this information
> > > >=20
> > > > > fully yet due to said unresponsiveness.
> > >=20
> > > Please try to collect /proc/vmstat in the bacground and provide the
> > > collected data. Something like
> > >=20
> > > while true
> > > do
> > >=20
> > > 	cp /proc/vmstat > vmstat.$(date +%s)
> > > 	sleep 1s
> > >=20
> > > done
> > >=20
> > > If the system turns out so busy that it won't be able to fork a proce=
ss
> > > or write the output (which you will see by checking timestamps of fil=
es
> > > and looking for holes) then you can try the attached proggy
> > > ./read_vmstat output_file timeout output_size
> > >=20
> > > Note you might need to increase the mlock rlimit to lock everything i=
nto
> > > memory.
> >=20
> > Thanks Michal,
> >=20
> > I have upgraded PCs since I initially put together this data - however I
> > was able to get strange behaviour by pulling out an 8Gb RAM stick in my
> > new system - leaving it with only 8Gb of RAM.
> >=20
> > All these tests are performed with Fedora 26 and kernel
> > 4.12.8-300.fc26.x86_64
> >=20
> > I have attached 3 files with output.
> >=20
> > 8Gb-noswap.tar.gz contains the output of /proc/vmstat running on 8Gb of
> > RAM
> > with no swap. Under this scenario, I was expecting the OOM reaper to ju=
st
> > kill the game when memory allocated became too high for the amount of
> > physical RAM. Interestingly, you'll notice a massive hang in the output
> > before the game is terminated. I didn't see this before.
>=20
> I have checked few gaps. E.g. vmstat.1503496391 vmstat.1503496451 which
> is one minute. The most notable thing is that there are only very few
> pagecache pages
> 			[base]		[diff]
> nr_active_file  	1641    	3345
> nr_inactive_file        1630    	4787
>=20
> So there is not much to reclaim without swap. The more important thing
> is that we keep reclaiming and refaulting that memory
>=20
> workingset_activate     5905591 	1616391
> workingset_refault      33412538        10302135
> pgactivate      	42279686        13219593
> pgdeactivate    	48175757        14833350
>=20
> pgscan_kswapd   	379431778       126407849
> pgsteal_kswapd  	49751559        13322930
>=20
> so we are effectivelly trashing over the very small amount of
> reclaimable memory. This is something that we cannot detect right now.
> It is even questionable whether the OOM killer would be an appropriate
> action. Your system has recovered and then it is always hard to decide
> whether a disruptive action is more appropriate. One minute of
> unresponsiveness is certainly annoying though. Your system is obviously
> under provisioned to load you want to run obviously.
>=20
> It is quite interesting to see that we do not really have too many
> direct reclaimers during this time period
> allocstall_normal       30      	1
> allocstall_movable      490     	88
> pgscan_direct_throttle  0       	0
> pgsteal_direct  	24434   	4069
> pgscan_direct   	38678   	5868

Yes, I understand that the system is really not suitable - however I believ=
e=20
the test is useful - even from an informational point of view :)

> > 8Gb-swap-on-file.tar.gz contains the output of /proc/vmstat still with =
8Gb
> > of RAM - but creating a file with swap on the PCIe SSD /swapfile with
> > size 8Gb>=20
> > via:
> > 	# dd if=3D/dev/zero of=3D/swapfile bs=3D1G count=3D8
> > 	# mkswap /swapfile
> > 	# swapon /swapfile
> >=20
> > Some times (all in UTC+10):
> > 23:58:30 - Start loading the saved game
> > 23:59:38 - Load ok, all running fine
> > 00:00:15 - Load Chrome
> > 00:01:00 - Quit the game
> >=20
> > The game seemed to run ok with no real issue - and a lot was swapped to
> > the
> > swap file. I'm wondering if it was purely the speed of the PCIe SSD that
> > caused this appearance - as the creation of the file with dd completed =
at
> > ~1.4GB/sec.
>=20
> Swap IO tends to be really scattered and the IO performance is not really
> great even on a fast storage AFAIK.
>=20
> Anyway your original report sounded like a regression. Were you able to
> run the _same_ workload on an older kernel without these issues?

When I try the same tests with swap on an SSD under kernel 4.10.x (I believ=
e=20
the latest I tried was 4.10.25?) - then swap using the SSD did not cause an=
y=20
issues or periods of system unresponsiveness.

The file attached in the original bug report "vmstat-4.10.17-10Gb.log" was=
=20
taken on my old system with 10Gb of RAM - and there were no significant pau=
ses=20
while swapping.

I do find it interesting that the newer '8Gb-swap-on-file.tar.gz' does not=
=20
show any issues. I wonder if it would be helpful to attempt the same using =
a=20
file on the SSD that was a swap disk in the '8Gb-swap-on-ssd.tar.gz' so we=
=20
have a constant device - but with a file on the SSD instead of the entire=20
block device. That would at least expose any issues on the same device in f=
ile=20
vs block mode? Or maybe even if there's a difference just having the file o=
n a=20
much (much!) faster drive?

=2D-=20
Steven Haigh

=F0=9F=93=A7 netwiz@crc.id.au       =F0=9F=92=BB http://www.crc.id.au
=F0=9F=93=9E +61 (3) 9001 6090    =F0=9F=93=B1 0412 935 897
--nextPart5469704.DWktjsOJT5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEFHf0gfgNrH6ofcYGQa811Xp9MdwFAlme4IwACgkQQa811Xp9
MdwTTA/9FGVwUpWQ9/IydveksU1IAts03jQQx4YztA2MZVsDwClWjo7W73UXDB2/
1d633b3GjK0OrSmSYli2iMJq+G41jRnM2gU5mkCXSiQKpymjywD2RiqShMl7+hQ2
svcWkylATJbRLkjpoZ27a2vg8S/GH8IzMvGHBXCsVGU6bgNis9WiuINNw0qf6qJd
RYY9L9PztQI/5n96VrQyb31WHsJWJhatTu/0S3LRTKFnLR30OPWrTthXRuAXHSsp
Xp8ze1HTstmIeDiwhnelMvFCWTxVVPjGUc0VFv3LLqvLhBVIj9NVNPsdlIYhy+iq
qmHp7+meNGt0h+AX+VgLAbyPQ/WcuUaXaYS07H6YAzMqSY2YKwu2PYDA4g7UilF3
pgNfM6qhvz8cUWcwj4e1wK7KyW6NrXDgbw+mpubuLdGCPrAZuBzT4c7aT7TQ9SE0
yyh1bqc4j5jzdXTEwnPQEf2VIl00SFOEBH75dUnfm00pdGt27KLWpsOfcl3yyp1d
7rqh6S3YRxDaZ0aHseLb8NkL/YkMayUiN77SZojoKvQqR18qFgXtbg09wZQGXnuz
JzMmaVJr0mgtmP/fmTdW12dFCw8KquSR38fvZqNYOBVyu10amfmwS0LY+HL6iigB
oVdeKX80D3aepq/dhMGbrnLt+BDXeYSQ1Bn3bqAFbqZNAEnRHo4=
=VE3c
-----END PGP SIGNATURE-----

--nextPart5469704.DWktjsOJT5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
