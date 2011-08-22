Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9CE056B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 16:32:41 -0400 (EDT)
Message-ID: <BLU165-W344B2B1CD9DC44A9DABA5DFF2F0@phx.gbl>
Content-Type: multipart/alternative;
	boundary="_214b1252-cb0c-4b79-a5c2-b40d0ced4b6c_"
From: Mark Petersen <mpete_06@hotmail.com>
Subject: RE: [Bugme-new] [Bug 41552] New: Performance of writing and reading
 from multiple drives decreases by 40% when going from Linux Kernel 2.6.36.4
 to 2.6.37 (and beyond)
Date: Mon, 22 Aug 2011 15:32:38 -0500
In-Reply-To: <20110822194854.GA15087@redhat.com>
References: 
 <bug-41552-10286@https.bugzilla.kernel.org/>,<20110822122443.c04839c8.akpm@linux-foundation.org>,<20110822194854.GA15087@redhat.com>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vgoyal@redhat.com
Cc: bugme-daemon@bugzilla.kernel.org, axboe@kernel.dk, linux-mm@kvack.org, linux-scsi@vger.kernel.org, akpm@linux-foundation.org

--_214b1252-cb0c-4b79-a5c2-b40d0ced4b6c_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


We were using the default CFQ scheduler.  I will change it to deadline and =
see what happens.  Also=2C we are not using a file system to perform the wr=
ites=2C rather we are sending SCSI commands directly to the devices=2C nor =
are we doing anything special to the disks with a device mapper.  We simply=
 write to each one on a different thread one sector at a time.

I will attempt to get the trace and will add it if I can.

Thanks=2C
Mark

> Date: Mon=2C 22 Aug 2011 15:48:54 -0400
> From: vgoyal@redhat.com
> To: mpete_06@hotmail.com
> CC: bugme-daemon@bugzilla.kernel.org=3B axboe@kernel.dk=3B linux-mm@kvack=
.org=3B linux-scsi@vger.kernel.org=3B akpm@linux-foundation.org
> Subject: Re: [Bugme-new] [Bug 41552] New: Performance of writing and read=
ing from multiple drives decreases by 40% when going from Linux Kernel 2.6.=
36.4 to 2.6.37 (and beyond)
>=20
> On Mon=2C Aug 22=2C 2011 at 12:24:43PM -0700=2C Andrew Morton wrote:
> >=20
> > (switched to email.  Please respond via emailed reply-to-all=2C not via=
 the
> > bugzilla web interface).
> >=20
> > On Mon=2C 22 Aug 2011 15:20:41 GMT
> > bugzilla-daemon@bugzilla.kernel.org wrote:
> >=20
> > > https://bugzilla.kernel.org/show_bug.cgi?id=3D41552
> > >=20
> > >            Summary: Performance of writing and reading from multiple
> > >                     drives decreases by 40% when going from Linux Ker=
nel
> > >                     2.6.36.4 to 2.6.37 (and beyond)
> > >            Product: IO/Storage
> > >            Version: 2.5
> > >     Kernel Version: 2.6.37
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: SCSI
> > >         AssignedTo: linux-scsi@vger.kernel.org
> > >         ReportedBy: mpete_06@hotmail.com
> > >         Regression: No
> > >=20
> > >=20
> > > We have an application that will write and read from every sector on =
a drive.=20
> > > The application can perform these tasks on multiple drives at the sam=
e time.=20
> > > It is designed to run on top of the Linux Kernel=2C which we periodic=
ally update
> > > so that we can get the latest device drivers.  When performing the la=
st update
> > > from 2.6.33.2 to 2.6.37=2C we found that the performance of a set of =
drives
> > > decreased by some 40% (took 3 hours and 11 minutes to write and read =
from 5
> > > drives on 2.6.37 versus 2 hours and 12 minutes on 2.6.33.3).  I was a=
ble to
> > > determine that the issue was in the 2.6.37 Kernel as I was able to ru=
n it with
> > > the 2.6.36.4 kernel=2C and it had the better performance.   After see=
ing that I/O
> > > throttling was introduced in the 2.6.37 Kernel=2C I naturally suspect=
ed that.=20
> > > However=2C by default=2C all the throttling was turned off (I attache=
d the actual
> > > .config that was used to build the kernel).  I then tried to turn on =
the
> > > throttling and set it to a high number to see what would happen.  Whe=
n I did
> > > that=2C I was able to reduce the time from 3 hours and 11 minutes to =
2 hours and
> > > 50 minutes.  There seems to be something there that changed that is i=
mpacting
> > > performance on multiple drives.  When we do this same test with only =
one drive=2C
> > > the performance is identical between the systems.  This issue still o=
ccurs on
> > > Kernel 3.0.2.
> > >=20
> >=20
> > Are you able to determine whether this regression is due to slower
> > reading=2C to slower writing or to both?
>=20
> Mark=2C
>=20
> As your initial comment says that you see 40% regression even when block
> throttling infrastructure is not enabled=2C I think it is not related to
> throttling as blk_throtl_bio() is null when BLK_DEV_THROTTLING=3Dn.
>=20
> What IO scheduler are you using? Can you try switching IO scheduler to
> deadline and see if regression is still there. Trying to figure out if
> it has anything to do with IO scheduler.
>=20
> What file system are you using with what options? Are you using device
> mapper to create some special configuration on multiple disks?
>=20
> Also can you take a trace (blktrace) of any of the disks for 30 seconds
> both without regression and after regression and upload it somewhere.
> Staring at it might give some clues.=20
>=20
> Thanks
> Vivek
 		 	   		  =

--_214b1252-cb0c-4b79-a5c2-b40d0ced4b6c_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<style><!--
.hmmessage P
{
margin:0px=3B
padding:0px
}
body.hmmessage
{
font-size: 10pt=3B
font-family:Tahoma
}
--></style>
</head>
<body class=3D'hmmessage'><div dir=3D'ltr'>
We were using the default CFQ scheduler.&nbsp=3B I will change it to deadli=
ne and see what happens.&nbsp=3B Also=2C we are not using a file system to =
perform the writes=2C rather we are sending SCSI commands directly to the d=
evices=2C nor are we doing anything special to the disks with a device mapp=
er.&nbsp=3B We simply write to each one on a different thread one sector at=
 a time.<br><br>I will attempt to get the trace and will add it if I can.<b=
r><br>Thanks=2C<br>Mark<br><br><div>&gt=3B Date: Mon=2C 22 Aug 2011 15:48:5=
4 -0400<br>&gt=3B From: vgoyal@redhat.com<br>&gt=3B To: mpete_06@hotmail.co=
m<br>&gt=3B CC: bugme-daemon@bugzilla.kernel.org=3B axboe@kernel.dk=3B linu=
x-mm@kvack.org=3B linux-scsi@vger.kernel.org=3B akpm@linux-foundation.org<b=
r>&gt=3B Subject: Re: [Bugme-new] [Bug 41552] New: Performance of writing a=
nd reading from multiple drives decreases by 40% when going from Linux Kern=
el 2.6.36.4 to 2.6.37 (and beyond)<br>&gt=3B <br>&gt=3B On Mon=2C Aug 22=2C=
 2011 at 12:24:43PM -0700=2C Andrew Morton wrote:<br>&gt=3B &gt=3B <br>&gt=
=3B &gt=3B (switched to email.  Please respond via emailed reply-to-all=2C =
not via the<br>&gt=3B &gt=3B bugzilla web interface).<br>&gt=3B &gt=3B <br>=
&gt=3B &gt=3B On Mon=2C 22 Aug 2011 15:20:41 GMT<br>&gt=3B &gt=3B bugzilla-=
daemon@bugzilla.kernel.org wrote:<br>&gt=3B &gt=3B <br>&gt=3B &gt=3B &gt=3B=
 https://bugzilla.kernel.org/show_bug.cgi?id=3D41552<br>&gt=3B &gt=3B &gt=
=3B <br>&gt=3B &gt=3B &gt=3B            Summary: Performance of writing and=
 reading from multiple<br>&gt=3B &gt=3B &gt=3B                     drives d=
ecreases by 40% when going from Linux Kernel<br>&gt=3B &gt=3B &gt=3B       =
              2.6.36.4 to 2.6.37 (and beyond)<br>&gt=3B &gt=3B &gt=3B      =
      Product: IO/Storage<br>&gt=3B &gt=3B &gt=3B            Version: 2.5<b=
r>&gt=3B &gt=3B &gt=3B     Kernel Version: 2.6.37<br>&gt=3B &gt=3B &gt=3B  =
         Platform: All<br>&gt=3B &gt=3B &gt=3B         OS/Version: Linux<br=
>&gt=3B &gt=3B &gt=3B               Tree: Mainline<br>&gt=3B &gt=3B &gt=3B =
            Status: NEW<br>&gt=3B &gt=3B &gt=3B           Severity: normal<=
br>&gt=3B &gt=3B &gt=3B           Priority: P1<br>&gt=3B &gt=3B &gt=3B     =
     Component: SCSI<br>&gt=3B &gt=3B &gt=3B         AssignedTo: linux-scsi=
@vger.kernel.org<br>&gt=3B &gt=3B &gt=3B         ReportedBy: mpete_06@hotma=
il.com<br>&gt=3B &gt=3B &gt=3B         Regression: No<br>&gt=3B &gt=3B &gt=
=3B <br>&gt=3B &gt=3B &gt=3B <br>&gt=3B &gt=3B &gt=3B We have an applicatio=
n that will write and read from every sector on a drive. <br>&gt=3B &gt=3B =
&gt=3B The application can perform these tasks on multiple drives at the sa=
me time. <br>&gt=3B &gt=3B &gt=3B It is designed to run on top of the Linux=
 Kernel=2C which we periodically update<br>&gt=3B &gt=3B &gt=3B so that we =
can get the latest device drivers.  When performing the last update<br>&gt=
=3B &gt=3B &gt=3B from 2.6.33.2 to 2.6.37=2C we found that the performance =
of a set of drives<br>&gt=3B &gt=3B &gt=3B decreased by some 40% (took 3 ho=
urs and 11 minutes to write and read from 5<br>&gt=3B &gt=3B &gt=3B drives =
on 2.6.37 versus 2 hours and 12 minutes on 2.6.33.3).  I was able to<br>&gt=
=3B &gt=3B &gt=3B determine that the issue was in the 2.6.37 Kernel as I wa=
s able to run it with<br>&gt=3B &gt=3B &gt=3B the 2.6.36.4 kernel=2C and it=
 had the better performance.   After seeing that I/O<br>&gt=3B &gt=3B &gt=
=3B throttling was introduced in the 2.6.37 Kernel=2C I naturally suspected=
 that. <br>&gt=3B &gt=3B &gt=3B However=2C by default=2C all the throttling=
 was turned off (I attached the actual<br>&gt=3B &gt=3B &gt=3B .config that=
 was used to build the kernel).  I then tried to turn on the<br>&gt=3B &gt=
=3B &gt=3B throttling and set it to a high number to see what would happen.=
  When I did<br>&gt=3B &gt=3B &gt=3B that=2C I was able to reduce the time =
from 3 hours and 11 minutes to 2 hours and<br>&gt=3B &gt=3B &gt=3B 50 minut=
es.  There seems to be something there that changed that is impacting<br>&g=
t=3B &gt=3B &gt=3B performance on multiple drives.  When we do this same te=
st with only one drive=2C<br>&gt=3B &gt=3B &gt=3B the performance is identi=
cal between the systems.  This issue still occurs on<br>&gt=3B &gt=3B &gt=
=3B Kernel 3.0.2.<br>&gt=3B &gt=3B &gt=3B <br>&gt=3B &gt=3B <br>&gt=3B &gt=
=3B Are you able to determine whether this regression is due to slower<br>&=
gt=3B &gt=3B reading=2C to slower writing or to both?<br>&gt=3B <br>&gt=3B =
Mark=2C<br>&gt=3B <br>&gt=3B As your initial comment says that you see 40% =
regression even when block<br>&gt=3B throttling infrastructure is not enabl=
ed=2C I think it is not related to<br>&gt=3B throttling as blk_throtl_bio()=
 is null when BLK_DEV_THROTTLING=3Dn.<br>&gt=3B <br>&gt=3B What IO schedule=
r are you using? Can you try switching IO scheduler to<br>&gt=3B deadline a=
nd see if regression is still there. Trying to figure out if<br>&gt=3B it h=
as anything to do with IO scheduler.<br>&gt=3B <br>&gt=3B What file system =
are you using with what options? Are you using device<br>&gt=3B mapper to c=
reate some special configuration on multiple disks?<br>&gt=3B <br>&gt=3B Al=
so can you take a trace (blktrace) of any of the disks for 30 seconds<br>&g=
t=3B both without regression and after regression and upload it somewhere.<=
br>&gt=3B Staring at it might give some clues. <br>&gt=3B <br>&gt=3B Thanks=
<br>&gt=3B Vivek<br></div> 		 	   		  </div></body>
</html>=

--_214b1252-cb0c-4b79-a5c2-b40d0ced4b6c_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
