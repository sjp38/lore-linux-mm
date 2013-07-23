Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 746306B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 00:58:24 -0400 (EDT)
From: Lisa Du <cldu@marvell.com>
Date: Mon, 22 Jul 2013 21:58:17 -0700
Subject: Possible deadloop in direct reclaim?
Message-ID: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_89813612683626448B837EE5A0B6A7CB3B62F8F272SCVEXCH4marve_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

--_000_89813612683626448B837EE5A0B6A7CB3B62F8F272SCVEXCH4marve_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Dear Sir:
Currently I met a possible deadloop in direct reclaim. After run plenty of =
the application, system run into a status that system memory is very fragme=
ntized. Like only order-0 and order-1 memory left.
Then one process required a order-2 buffer but it enter an endless direct r=
eclaim. From my trace log, I can see this loop already over 200,000 times. =
Kswapd was first wake up and then go back to sleep as it cannot rebalance t=
his order's memory. But zone->all_unreclaimable remains 1.
Though direct_reclaim every time returns no pages, but as zone->all_unrecla=
imable =3D 1, so it loop again and again. Even when zone->pages_scanned als=
o becomes very large. It will block the process for long time, until some w=
atchdog thread detect this and kill this process. Though it's in __alloc_pa=
ges_slowpath, but it's too slow right? Maybe cost over 50 seconds or even m=
ore.
I think it's not as expected right?  Can we also add below check in the fun=
ction all_unreclaimable() to terminate this loop?

@@ -2355,6 +2355,8 @@ static bool all_unreclaimable(struct zonelist *zoneli=
st,
                        continue;
                if (!zone->all_unreclaimable)
                        return false;
+               if (sc->nr_reclaimed =3D=3D 0 && !zone_reclaimable(zone))
+                       return true;
        }
         BTW: I'm using kernel3.4, I also try to search in the kernel3.9, d=
idn't see a possible fix for such issue. Or is anyone also met such issue b=
efore? Any comment will be welcomed, looking forward to your reply!

Thanks!

Best Regards
Lisa Du


--_000_89813612683626448B837EE5A0B6A7CB3B62F8F272SCVEXCH4marve_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:x=3D"urn:schemas-microsoft-com:office:excel" xmlns:p=3D"urn:schemas-m=
icrosoft-com:office:powerpoint" xmlns:a=3D"urn:schemas-microsoft-com:office=
:access" xmlns:dt=3D"uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" xmlns:s=3D"=
uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882" xmlns:rs=3D"urn:schemas-microsof=
t-com:rowset" xmlns:z=3D"#RowsetSchema" xmlns:b=3D"urn:schemas-microsoft-co=
m:office:publisher" xmlns:ss=3D"urn:schemas-microsoft-com:office:spreadshee=
t" xmlns:c=3D"urn:schemas-microsoft-com:office:component:spreadsheet" xmlns=
:odc=3D"urn:schemas-microsoft-com:office:odc" xmlns:oa=3D"urn:schemas-micro=
soft-com:office:activation" xmlns:html=3D"http://www.w3.org/TR/REC-html40" =
xmlns:q=3D"http://schemas.xmlsoap.org/soap/envelope/" xmlns:rtc=3D"http://m=
icrosoft.com/officenet/conferencing" xmlns:D=3D"DAV:" xmlns:Repl=3D"http://=
schemas.microsoft.com/repl/" xmlns:mt=3D"http://schemas.microsoft.com/share=
point/soap/meetings/" xmlns:x2=3D"http://schemas.microsoft.com/office/excel=
/2003/xml" xmlns:ppda=3D"http://www.passport.com/NameSpace.xsd" xmlns:ois=
=3D"http://schemas.microsoft.com/sharepoint/soap/ois/" xmlns:dir=3D"http://=
schemas.microsoft.com/sharepoint/soap/directory/" xmlns:ds=3D"http://www.w3=
.org/2000/09/xmldsig#" xmlns:dsp=3D"http://schemas.microsoft.com/sharepoint=
/dsp" xmlns:udc=3D"http://schemas.microsoft.com/data/udc" xmlns:xsd=3D"http=
://www.w3.org/2001/XMLSchema" xmlns:sub=3D"http://schemas.microsoft.com/sha=
repoint/soap/2002/1/alerts/" xmlns:ec=3D"http://www.w3.org/2001/04/xmlenc#"=
 xmlns:sp=3D"http://schemas.microsoft.com/sharepoint/" xmlns:sps=3D"http://=
schemas.microsoft.com/sharepoint/soap/" xmlns:xsi=3D"http://www.w3.org/2001=
/XMLSchema-instance" xmlns:udcs=3D"http://schemas.microsoft.com/data/udc/so=
ap" xmlns:udcxf=3D"http://schemas.microsoft.com/data/udc/xmlfile" xmlns:udc=
p2p=3D"http://schemas.microsoft.com/data/udc/parttopart" xmlns:wf=3D"http:/=
/schemas.microsoft.com/sharepoint/soap/workflow/" xmlns:dsss=3D"http://sche=
mas.microsoft.com/office/2006/digsig-setup" xmlns:dssi=3D"http://schemas.mi=
crosoft.com/office/2006/digsig" xmlns:mdssi=3D"http://schemas.openxmlformat=
s.org/package/2006/digital-signature" xmlns:mver=3D"http://schemas.openxmlf=
ormats.org/markup-compatibility/2006" xmlns:m=3D"http://schemas.microsoft.c=
om/office/2004/12/omml" xmlns:mrels=3D"http://schemas.openxmlformats.org/pa=
ckage/2006/relationships" xmlns:spwp=3D"http://microsoft.com/sharepoint/web=
partpages" xmlns:ex12t=3D"http://schemas.microsoft.com/exchange/services/20=
06/types" xmlns:ex12m=3D"http://schemas.microsoft.com/exchange/services/200=
6/messages" xmlns:pptsl=3D"http://schemas.microsoft.com/sharepoint/soap/Sli=
deLibrary/" xmlns:spsl=3D"http://microsoft.com/webservices/SharePointPortal=
Server/PublishedLinksService" xmlns:Z=3D"urn:schemas-microsoft-com:" xmlns:=
st=3D"&#1;" xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=3DContent-Type content=3D"text/html; charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 12 (filtered medium)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	text-justify:inter-ideograph;
	font-size:10.5pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;}
 /* Page Definitions */
 @page Section1
	{size:612.0pt 792.0pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.Section1
	{page:Section1;}
-->
</style>
<!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext=3D"edit">
  <o:idmap v:ext=3D"edit" data=3D"1" />
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=3DZH-CN link=3Dblue vlink=3Dpurple style=3D'text-justify-trim:pu=
nctuation'>

<div class=3DSection1>

<p class=3DMsoNormal><span lang=3DEN-US>Dear Sir:<o:p></o:p></span></p>

<p class=3DMsoNormal style=3D'text-indent:21.0pt'><span lang=3DEN-US>Curren=
tly I met
a possible deadloop in direct reclaim. After run plenty of the application,
system run into a status that system memory is very fragmentized. Like only
order-0 and order-1 memory left. <o:p></o:p></span></p>

<p class=3DMsoNormal style=3D'text-indent:21.0pt'><span lang=3DEN-US>Then o=
ne process
required a order-2 buffer but it enter an endless direct reclaim. From my t=
race
log, I can see this loop already over 200,000 times. Kswapd was first wake =
up
and then go back to sleep as it cannot rebalance this order&#8217;s memory.=
 But
zone-&gt;all_unreclaimable remains 1.<o:p></o:p></span></p>

<p class=3DMsoNormal style=3D'text-indent:21.0pt'><span lang=3DEN-US>Though
direct_reclaim every time returns no pages, but as zone-&gt;all_unreclaimab=
le =3D
1, so it loop again and again. Even when zone-&gt;pages_scanned also become=
s
very large. It will block the process for long time, until some watchdog th=
read
detect this and kill this process. Though it&#8217;s in __alloc_pages_slowp=
ath,
but it&#8217;s too slow right? Maybe cost over 50 seconds or even more.<o:p=
></o:p></span></p>

<p class=3DMsoNormal style=3D'text-indent:21.0pt'><span lang=3DEN-US>I thin=
k it&#8217;s
not as expected right? &nbsp;Can we also add below check in the function al=
l_unreclaimable()
to terminate this loop?<o:p></o:p></span></p>

<p class=3DMsoNormal style=3D'text-indent:21.0pt'><span lang=3DEN-US><o:p>&=
nbsp;</o:p></span></p>

<p class=3DMsoNormal style=3D'text-indent:21.0pt'><span lang=3DEN-US>@@ -23=
55,6
+2355,8 @@ static bool all_unreclaimable(struct zonelist *zonelist,<o:p></o=
:p></span></p>

<p class=3DMsoNormal style=3D'text-indent:21.0pt'><span lang=3DEN-US>&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
continue;<o:p></o:p></span></p>

<p class=3DMsoNormal style=3D'text-indent:21.0pt'><span lang=3DEN-US>&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;
if (!zone-&gt;all_unreclaimable)<o:p></o:p></span></p>

<p class=3DMsoNormal style=3D'text-indent:21.0pt'><span lang=3DEN-US>&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
return false;<o:p></o:p></span></p>

<p class=3DMsoNormal style=3D'text-indent:21.0pt'><span lang=3DEN-US>+&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;
if (sc-&gt;nr_reclaimed =3D=3D 0 &amp;&amp; !zone_reclaimable(zone))<o:p></=
o:p></span></p>

<p class=3DMsoNormal style=3D'text-indent:21.0pt'><span lang=3DEN-US>+&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
return true;<o:p></o:p></span></p>

<p class=3DMsoNormal style=3D'text-indent:21.0pt'><span lang=3DEN-US>&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
}<o:p></o:p></span></p>

<p class=3DMsoNormal><span lang=3DEN-US>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp; BTW:
I&#8217;m using kernel3.4, I also try to search in the kernel3.9, didn&#821=
7;t
see a possible fix for such issue. Or is anyone also met such issue before?=
 Any
comment will be welcomed, looking forward to your reply!<o:p></o:p></span><=
/p>

<p class=3DMsoNormal><span lang=3DEN-US><o:p>&nbsp;</o:p></span></p>

<p class=3DMsoNormal><span lang=3DEN-US>Thanks!<o:p></o:p></span></p>

<p class=3DMsoNormal><span lang=3DEN-US><o:p>&nbsp;</o:p></span></p>

<p class=3DMsoNormal><span lang=3DEN-US>Best Regards<o:p></o:p></span></p>

<p class=3DMsoNormal><span lang=3DEN-US>Lisa Du<o:p></o:p></span></p>

<p class=3DMsoNormal><span lang=3DEN-US><o:p>&nbsp;</o:p></span></p>

</div>

</body>

</html>

--_000_89813612683626448B837EE5A0B6A7CB3B62F8F272SCVEXCH4marve_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
