Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 5627E6B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 01:32:45 -0400 (EDT)
From: Shawn Joo <sjoo@nvidia.com>
Date: Tue, 31 Jul 2012 13:32:36 +0800
Subject: RE: page allocation failure
Message-ID: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157B9DA@HKMAIL02.nvidia.com>
References: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157B900@HKMAIL02.nvidia.com>
 <20120730141329.GC9981@tiehlicka.suse.cz>
In-Reply-To: <20120730141329.GC9981@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_5F2C6DA655B36C43B21C7FB179CEC9F4E3F157B9DAHKMAIL02nvidi_"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "andi@firstfloor.org" <andi@firstfloor.org>

--_000_5F2C6DA655B36C43B21C7FB179CEC9F4E3F157B9DAHKMAIL02nvidi_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Thank you for attention and comment, here is following question.



1.     In general if order 3(32KB) is required to be allocated, if "size-=
32768" cache does not have available slab, then "size-32768" will request=
=20memory from buddy Here watermark is involved as important factor.

(I would like to know how to increase the number of object on the cache, =
because when cache is created by "kmem_cache_create", there is only objec=
t size, but no number of the object)

=F0  my understanding is correct?, please correct.



2.     In my init.rc, min_free_order_shift is set to 4.

If I decrease this value, it should be helpful.

any recommend size of "min_free_order_shift"? If I can have doc about it,=
=20it will be helpful.



>> Although you have some order-3 pages the Normal zone is not balanced f=
or that order most probably (see __zone_watermark_ok).

I am afraid that I am not familiar with "watermark", anyway I will study =
in detail.

Looks "is not balanced" is related to watermark.





Thanks,

Seongho(Shawn)



-----Original Message-----
From: Michal Hocko [mailto:mhocko@suse.cz]<mailto:[mailto:mhocko@suse.cz]=
>
Sent: Monday, July 30, 2012 11:13 PM
To: Shawn Joo
Cc: linux-mm@kvack.org<mailto:linux-mm@kvack.org>; andi@firstfloor.org<ma=
ilto:andi@firstfloor.org>
Subject: Re: page allocation failure



On Mon 30-07-12 21:25:40, Shawn Joo wrote:

> Dear experts,

>

> I have question about memory allocation failure on kernel 3.1. (simply

> it seems there is available free memory, however "page allocation

> failure" happened)

>

> While big data transfer, there is page allocation failure (please

> check attached log) It happens on __alloc_skb().  Inside function, it

> allocates memory from "skbuff_head_cache" and "size-xxxxxxx" caches.

>

> Here is my understanding, please correct me and advise.  From the

> kernel log, it failed when it tried to get 2^3*4K(=3D32KB) memory. (e.g=
.

> swapper: page allocation failure: order:3, mode:0x20)



You are actually short on free memory (7M out of 700M). Although you have=
=20some order-3 pages the Normal zone is not balanced for that order most=
=20probably (see __zone_watermark_ok). Your allocation is GFP_ATOMIC and =
that's why the process cannot sleep and wait for reclaim to free enough p=
ages to satisfy this allocation.



> From slabinfo, upper size-32768 does not have available slab, however

> buddy still has available memory. so when 32KB(order:3) was required,

> slab(size-32768) should request memory from buddy. e.g. "2" will be

> decreased to "1" on buddyinfo and "size-32768" cache will get 32K

> memory from buddy.  So I can not understand why page alloc failure

> happened even if there are many available memory on buddy.  Please

> advise on it.

>

> Here is dump info(page_allocation_failure_last_dump.txt), right after

> issue happens.

> (FYI at alloc failure, order:3)

> cat /proc/buddyinfo

> Node 0, zone   Normal    949      0      0      2      3      3      0 =
=20    0      1      1      0

>

> root@android:/sdcard/modem_CoreDump # cat /proc/meminfo cat

> /proc/meminfo

> MemTotal:         747864 kB

> MemFree:            7000 kB

> Buffers:            5596 kB

> Cached:           361884 kB

> SwapCached:            0 kB

> Active:           147068 kB

> Inactive:         333448 kB

> Active(anon):     113212 kB

> Inactive(anon):      296 kB

> Active(file):      33856 kB

> Inactive(file):   333152 kB

> Unevictable:          96 kB

> Mlocked:               0 kB

> HighTotal:             0 kB

> HighFree:              0 kB

> LowTotal:         747864 kB

> LowFree:            7000 kB

> SwapTotal:             0 kB

> SwapFree:              0 kB

> Dirty:                 0 kB

> Writeback:             0 kB

> AnonPages:        113172 kB

> Mapped:            44288 kB

> Shmem:               376 kB

> Slab:              15280 kB

> SReclaimable:       7976 kB

> SUnreclaim:         7304 kB

> KernelStack:        3712 kB

> PageTables:         5628 kB

> NFS_Unstable:          0 kB

> Bounce:                0 kB

> WritebackTmp:          0 kB

> CommitLimit:      373932 kB

> Committed_AS:    2894244 kB

> VmallocTotal:     131072 kB

> VmallocUsed:       39136 kB

> VmallocChunk:      76676 kB

> DirectMap4k:      399364 kB

> DirectMap2M:      370688 kB

--

Michal Hocko

SUSE Labs

-------------------------------------------------------------------------=
----------
This email message is for the sole use of the intended recipient(s) and m=
ay contain
confidential information.  Any unauthorized review, use, disclosure or di=
stribution
is prohibited.  If you are not the intended recipient, please contact the=
=20sender by
reply email and destroy all copies of the original message.
-------------------------------------------------------------------------=
----------

--_000_5F2C6DA655B36C43B21C7FB179CEC9F4E3F157B9DAHKMAIL02nvidi_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-mi=
crosoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:wo=
rd" xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D=
"http://www.w3.org/TR/REC-html40"><head><meta http-equiv=3DContent-Type c=
ontent=3D"text/html; charset=3Diso-8859-1"><meta name=3DGenerator content=
=3D"Microsoft Word 14 (filtered medium)"><style><!--
/* Font Definitions */
@font-face
=09{font-family:Wingdings;
=09panose-1:5 0 0 0 0 0 0 0 0 0;}
@font-face
=09{font-family:Gulim;
=09panose-1:2 11 6 0 0 1 1 1 1 1;}
@font-face
=09{font-family:Gulim;
=09panose-1:2 11 6 0 0 1 1 1 1 1;}
@font-face
=09{font-family:"Malgun Gothic";
=09panose-1:2 11 5 3 2 0 0 2 0 4;}
@font-face
=09{font-family:Tahoma;
=09panose-1:2 11 6 4 3 5 4 4 2 4;}
@font-face
=09{font-family:"Malgun Gothic";
=09panose-1:2 11 5 3 2 0 0 2 0 4;}
@font-face
=09{font-family:Gulim;
=09panose-1:2 11 6 0 0 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
=09{margin:0cm;
=09margin-bottom:.0001pt;
=09font-size:11.0pt;
=09font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
=09{mso-style-priority:99;
=09color:blue;
=09text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
=09{mso-style-priority:99;
=09color:purple;
=09text-decoration:underline;}
p.MsoPlainText, li.MsoPlainText, div.MsoPlainText
=09{mso-style-priority:99;
=09mso-style-link:"Plain Text Char";
=09margin:0cm;
=09margin-bottom:.0001pt;
=09font-size:10.0pt;
=09font-family:"Malgun Gothic";}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
=09{mso-style-priority:99;
=09mso-style-link:"Balloon Text Char";
=09margin:0cm;
=09margin-bottom:.0001pt;
=09font-size:8.0pt;
=09font-family:"Tahoma","sans-serif";}
span.PlainTextChar
=09{mso-style-name:"Plain Text Char";
=09mso-style-priority:99;
=09mso-style-link:"Plain Text";
=09font-family:"Malgun Gothic";}
span.EmailStyle20
=09{mso-style-type:personal-compose;}
span.BalloonTextChar
=09{mso-style-name:"Balloon Text Char";
=09mso-style-priority:99;
=09mso-style-link:"Balloon Text";
=09font-family:"Tahoma","sans-serif";}
.MsoChpDefault
=09{mso-style-type:export-only;
=09font-size:10.0pt;
=09font-family:"Calibri","sans-serif";}
@page WordSection1
=09{size:612.0pt 792.0pt;
=09margin:3.0cm 72.0pt 72.0pt 72.0pt;}
div.WordSection1
=09{page:WordSection1;}
/* List Definitions */
@list l0
=09{mso-list-id:1861091434;
=09mso-list-type:hybrid;
=09mso-list-template-ids:2107550402 67698703 67698713 67698715 67698703 6=
7698713 67698715 67698703 67698713 67698715;}
@list l0:level1
=09{mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09text-indent:-18.0pt;}
@list l0:level2
=09{mso-level-number-format:alpha-lower;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09text-indent:-18.0pt;}
@list l0:level3
=09{mso-level-number-format:roman-lower;
=09mso-level-tab-stop:none;
=09mso-level-number-position:right;
=09text-indent:-9.0pt;}
@list l0:level4
=09{mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09text-indent:-18.0pt;}
@list l0:level5
=09{mso-level-number-format:alpha-lower;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09text-indent:-18.0pt;}
@list l0:level6
=09{mso-level-number-format:roman-lower;
=09mso-level-tab-stop:none;
=09mso-level-number-position:right;
=09text-indent:-9.0pt;}
@list l0:level7
=09{mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09text-indent:-18.0pt;}
@list l0:level8
=09{mso-level-number-format:alpha-lower;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09text-indent:-18.0pt;}
@list l0:level9
=09{mso-level-number-format:roman-lower;
=09mso-level-tab-stop:none;
=09mso-level-number-position:right;
=09text-indent:-9.0pt;}
@list l1
=09{mso-list-id:1900482846;
=09mso-list-type:hybrid;
=09mso-list-template-ids:-1307287218 472646902 67698691 67698693 67698689=
=2067698691 67698693 67698689 67698691 67698693;}
@list l1:level1
=09{mso-level-number-format:bullet;
=09mso-level-text:\F0F0;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09margin-left:54.0pt;
=09text-indent:-18.0pt;
=09font-family:Wingdings;
=09mso-fareast-font-family:"Malgun Gothic";
=09mso-bidi-font-family:Gulim;}
@list l1:level2
=09{mso-level-number-format:bullet;
=09mso-level-text:o;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09margin-left:90.0pt;
=09text-indent:-18.0pt;
=09font-family:"Courier New";}
@list l1:level3
=09{mso-level-number-format:bullet;
=09mso-level-text:\F0A7;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09margin-left:126.0pt;
=09text-indent:-18.0pt;
=09font-family:Wingdings;}
@list l1:level4
=09{mso-level-number-format:bullet;
=09mso-level-text:\F0B7;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09margin-left:162.0pt;
=09text-indent:-18.0pt;
=09font-family:Symbol;}
@list l1:level5
=09{mso-level-number-format:bullet;
=09mso-level-text:o;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09margin-left:198.0pt;
=09text-indent:-18.0pt;
=09font-family:"Courier New";}
@list l1:level6
=09{mso-level-number-format:bullet;
=09mso-level-text:\F0A7;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09margin-left:234.0pt;
=09text-indent:-18.0pt;
=09font-family:Wingdings;}
@list l1:level7
=09{mso-level-number-format:bullet;
=09mso-level-text:\F0B7;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09margin-left:270.0pt;
=09text-indent:-18.0pt;
=09font-family:Symbol;}
@list l1:level8
=09{mso-level-number-format:bullet;
=09mso-level-text:o;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09margin-left:306.0pt;
=09text-indent:-18.0pt;
=09font-family:"Courier New";}
@list l1:level9
=09{mso-level-number-format:bullet;
=09mso-level-text:\F0A7;
=09mso-level-tab-stop:none;
=09mso-level-number-position:left;
=09margin-left:342.0pt;
=09text-indent:-18.0pt;
=09font-family:Wingdings;}
ol
=09{margin-bottom:0cm;}
ul
=09{margin-bottom:0cm;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]--></head><body lang=3DEN-US link=3Dblue v=
link=3Dpurple><div class=3DWordSection1><p class=3DMsoPlainText>Thank you=
=20for attention and comment, here is following question.<o:p></o:p></p><=
p class=3DMsoPlainText><o:p>&nbsp;</o:p></p><p class=3DMsoPlainText style=
=3D'margin-left:36.0pt;text-indent:-18.0pt;mso-list:l0 level1 lfo1'><![if=
=20!supportLists]><span style=3D'mso-list:Ignore'>1.<span style=3D'font:7=
.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp; </span></span><![endif]>=
<u>In general</u> if order 3(32KB) is required to be allocated, if &#8220=
;size-32768&#8221; cache does not have available slab, then &#8220;size-3=
2768&#8221; will request memory from buddy Here watermark is involved as =
important factor.<o:p></o:p></p><p class=3DMsoPlainText style=3D'margin-l=
eft:36.0pt'>(I would like to know <u>how to increase the number of object=
=20on the cache</u>, because when cache is created by &#8220;kmem_cache_c=
reate&#8221;, there is only object size, but no number of the object)<o:p=
></o:p></p><p class=3DMsoPlainText style=3D'margin-left:54.0pt;text-inden=
t:-18.0pt;mso-list:l1 level1 lfo2'><![if !supportLists]><span style=3D'fo=
nt-family:Wingdings;background:yellow;mso-highlight:yellow'><span style=3D=
'mso-list:Ignore'>=F0<span style=3D'font:7.0pt "Times New Roman"'>&nbsp; =
</span></span></span><![endif]><span style=3D'background:yellow;mso-highl=
ight:yellow'>my understanding is correct?, please correct.<o:p></o:p></sp=
an></p><p class=3DMsoPlainText><o:p>&nbsp;</o:p></p><p class=3DMsoPlainTe=
xt style=3D'margin-left:36.0pt;text-indent:-18.0pt;mso-list:l0 level1 lfo=
1'><![if !supportLists]><span style=3D'mso-list:Ignore'>2.<span style=3D'=
font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp; </span></span><![e=
ndif]>In my init.rc, min_free_order_shift is set to 4.<o:p></o:p></p><p c=
lass=3DMsoPlainText style=3D'margin-left:36.0pt'>If I decrease this value=
, it should be helpful.<o:p></o:p></p><p class=3DMsoPlainText style=3D'ma=
rgin-left:36.0pt'>any recommend size of &#8220;min_free_order_shift&#8221=
;? If I can have doc about it, it will be helpful.<o:p></o:p></p><p class=
=3DMsoPlainText><o:p>&nbsp;</o:p></p><p class=3DMsoPlainText><span style=3D=
'font-size:9.0pt'>&gt;&gt; Although you have some order-3 pages the Norma=
l zone <u>is not balanced</u> for that order most probably (see __zone_wa=
termark_ok).<o:p></o:p></span></p><p class=3DMsoPlainText>I am afraid tha=
t I am not familiar with <span lang=3DKO>&#8220;</span>watermark&#8221;, =
anyway I will study in detail.<o:p></o:p></p><p class=3DMsoPlainText>Look=
s &#8220;is not balanced&#8221; is related to watermark.<o:p></o:p></p><p=
=20class=3DMsoPlainText><o:p>&nbsp;</o:p></p><p class=3DMsoPlainText><o:p=
>&nbsp;</o:p></p><p class=3DMsoPlainText>Thanks,<o:p></o:p></p><p class=3D=
MsoPlainText>Seongho(Shawn)<o:p></o:p></p><p class=3DMsoPlainText><o:p>&n=
bsp;</o:p></p><p class=3DMsoPlainText>-----Original Message-----<br>From:=
=20Michal Hocko <a href=3D"mailto:[mailto:mhocko@suse.cz]">[mailto:mhocko=
@suse.cz]</a> <br>Sent: Monday, July 30, 2012 11:13 PM<br>To: Shawn Joo<b=
r>Cc: <a href=3D"mailto:linux-mm@kvack.org">linux-mm@kvack.org</a>; <a hr=
ef=3D"mailto:andi@firstfloor.org">andi@firstfloor.org</a><br>Subject: Re:=
=20page allocation failure<o:p></o:p></p><p class=3DMsoPlainText><o:p>&nb=
sp;</o:p></p><p class=3DMsoPlainText>On Mon 30-07-12 21:25:40, Shawn Joo =
wrote:<o:p></o:p></p><p class=3DMsoPlainText>&gt; Dear experts,<o:p></o:p=
></p><p class=3DMsoPlainText>&gt; <o:p></o:p></p><p class=3DMsoPlainText>=
&gt; I have question about memory allocation failure on kernel 3.1. (simp=
ly <o:p></o:p></p><p class=3DMsoPlainText>&gt; it seems there is availabl=
e free memory, however &quot;page allocation <o:p></o:p></p><p class=3DMs=
oPlainText>&gt; failure&quot; happened)<o:p></o:p></p><p class=3DMsoPlain=
Text>&gt;<o:p>&nbsp;</o:p></p><p class=3DMsoPlainText>&gt; While big data=
=20transfer, there is page allocation failure (please <o:p></o:p></p><p c=
lass=3DMsoPlainText>&gt; check attached log) It happens on __alloc_skb().=
=A0 Inside function, it <o:p></o:p></p><p class=3DMsoPlainText>&gt; alloc=
ates memory from &quot;skbuff_head_cache&quot; and &quot;size-xxxxxxx&quo=
t; caches.<o:p></o:p></p><p class=3DMsoPlainText>&gt;<o:p>&nbsp;</o:p></p=
><p class=3DMsoPlainText>&gt; Here is my understanding, please correct me=
=20and advise.=A0 From the <o:p></o:p></p><p class=3DMsoPlainText>&gt; ke=
rnel log, it failed when it tried to get 2^3*4K(=3D32KB) memory. (e.g.<o:=
p></o:p></p><p class=3DMsoPlainText>&gt; swapper: page allocation failure=
: order:3, mode:0x20)<o:p></o:p></p><p class=3DMsoPlainText><o:p>&nbsp;</=
o:p></p><p class=3DMsoPlainText>You are actually short on free memory (7M=
=20out of 700M). Although you have some order-3 pages the Normal zone is =
not balanced for that order most probably (see __zone_watermark_ok). Your=
=20allocation is GFP_ATOMIC and that's why the process cannot sleep and w=
ait for reclaim to free enough pages to satisfy this allocation.<o:p></o:=
p></p><p class=3DMsoPlainText><o:p>&nbsp;</o:p></p><p class=3DMsoPlainTex=
t>&gt; From slabinfo, upper size-32768 does not have available slab, howe=
ver <o:p></o:p></p><p class=3DMsoPlainText>&gt; buddy still has available=
=20memory. so when 32KB(order:3) was required,<o:p></o:p></p><p class=3DM=
soPlainText>&gt; slab(size-32768) should request memory from buddy. e.g. =
&quot;2&quot; will be <o:p></o:p></p><p class=3DMsoPlainText>&gt; decreas=
ed to &quot;1&quot; on buddyinfo and &quot;size-32768&quot; cache will ge=
t 32K <o:p></o:p></p><p class=3DMsoPlainText>&gt; memory from buddy.=A0 S=
o I can not understand why page alloc failure <o:p></o:p></p><p class=3DM=
soPlainText>&gt; happened even if there are many available memory on budd=
y.=A0 Please <o:p></o:p></p><p class=3DMsoPlainText>&gt; advise on it.<o:=
p></o:p></p><p class=3DMsoPlainText>&gt;<o:p>&nbsp;</o:p></p><p class=3DM=
soPlainText>&gt; Here is dump info(page_allocation_failure_last_dump.txt)=
, right after <o:p></o:p></p><p class=3DMsoPlainText>&gt; issue happens.<=
o:p></o:p></p><p class=3DMsoPlainText>&gt; (FYI at alloc failure, order:3=
)<o:p></o:p></p><p class=3DMsoPlainText>&gt; cat /proc/buddyinfo<o:p></o:=
p></p><p class=3DMsoPlainText>&gt; Node 0, zone=A0=A0 Normal=A0=A0=A0 949=
=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 3=A0=A0=
=A0=A0=A0 3=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=
=A0 1=A0=A0=A0=A0=A0 0<o:p></o:p></p><p class=3DMsoPlainText>&gt; <o:p></=
o:p></p><p class=3DMsoPlainText>&gt; root@android:/sdcard/modem_CoreDump =
# cat /proc/meminfo cat <o:p></o:p></p><p class=3DMsoPlainText>&gt; /proc=
/meminfo<o:p></o:p></p><p class=3DMsoPlainText>&gt; MemTotal:=A0=A0=A0=A0=
=A0=A0=A0=A0 747864 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; MemFree=
:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 7000 kB<o:p></o:p></p><p class=3DMsoPl=
ainText>&gt; Buffers:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 5596 kB<o:p></o:p>=
</p><p class=3DMsoPlainText>&gt; Cached:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 36=
1884 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; SwapCached:=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 0 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; Act=
ive:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 147068 kB<o:p></o:p></p><p class=3DMso=
PlainText>&gt; Inactive:=A0=A0=A0=A0=A0=A0=A0=A0 333448 kB<o:p></o:p></p>=
<p class=3DMsoPlainText>&gt; Active(anon):=A0=A0=A0=A0 113212 kB<o:p></o:=
p></p><p class=3DMsoPlainText>&gt; Inactive(anon):=A0=A0=A0=A0=A0 296 kB<=
o:p></o:p></p><p class=3DMsoPlainText>&gt; Active(file):=A0=A0=A0=A0=A0 3=
3856 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; Inactive(file):=A0=A0 =
333152 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; Unevictable:=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 96 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; Mlock=
ed:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB<o:p></o:p></p><p class=
=3DMsoPlainText>&gt; HighTotal:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB<=
o:p></o:p></p><p class=3DMsoPlainText>&gt; HighFree:=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 =A0=A0=A00 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; LowTot=
al:=A0=A0=A0=A0=A0=A0=A0=A0 747864 kB<o:p></o:p></p><p class=3DMsoPlainTe=
xt>&gt; LowFree:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 7000 kB<o:p></o:p></p><=
p class=3DMsoPlainText>&gt; SwapTotal:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=200 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; SwapFree:=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0 0 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; =
Dirty:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB<o:p></o:p></p=
><p class=3DMsoPlainText>&gt; Writeback:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 0 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; AnonPages:=A0=A0=A0=A0=
=A0=A0=A0 113172 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; Mapped:=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 44288 kB<o:p></o:p></p><p class=3DMsoPlain=
Text>&gt; Shmem:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 376 kB<o:p></o=
:p></p><p class=3DMsoPlainText>&gt; Slab:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 15280 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; SReclaimable:=A0=
=A0=A0=A0=A0=A0 7976 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; SUnrec=
laim:=A0=A0=A0=A0=A0=A0=A0=A0 7304 kB<o:p></o:p></p><p class=3DMsoPlainTe=
xt>&gt; KernelStack:=A0=A0=A0=A0=A0=A0=A0 3712 kB<o:p></o:p></p><p class=3D=
MsoPlainText>&gt; PageTables:=A0=A0=A0=A0=A0=A0=A0=A0 5628 kB<o:p></o:p><=
/p><p class=3DMsoPlainText>&gt; NFS_Unstable:=A0=A0=A0=A0=A0=A0=A0=A0=A0 =
0 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; Bounce:=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB<o:p></o:p></p><p class=3DMsoPlainText>&g=
t; WritebackTmp:=A0=A0=A0=A0=A0=A0=A0=A0 =A00 kB<o:p></o:p></p><p class=3D=
MsoPlainText>&gt; CommitLimit:=A0=A0=A0=A0=A0 373932 kB<o:p></o:p></p><p =
class=3DMsoPlainText>&gt; Committed_AS:=A0=A0=A0 2894244 kB<o:p></o:p></p=
><p class=3DMsoPlainText>&gt; VmallocTotal:=A0=A0=A0=A0 131072 kB<o:p></o=
:p></p><p class=3DMsoPlainText>&gt; VmallocUsed:=A0=A0=A0=A0=A0=A0 39136 =
kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; VmallocChunk:=A0=A0=A0=A0=A0=
=2076676 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; DirectMap4k:=A0=A0=
=A0=A0=A0 399364 kB<o:p></o:p></p><p class=3DMsoPlainText>&gt; DirectMap2=
M:=A0=A0=A0=A0=A0 370688 kB<o:p></o:p></p><p class=3DMsoPlainText>--<o:p>=
</o:p></p><p class=3DMsoPlainText>Michal Hocko<o:p></o:p></p><p class=3DM=
soPlainText>SUSE Labs<o:p></o:p></p></div>
<DIV>
<HR>
</DIV>
<DIV>This email message is for the sole use of the intended recipient(s) =
and may=20
contain confidential information.&nbsp; Any unauthorized review, use, dis=
closure=20
or distribution is prohibited.&nbsp; If you are not the intended recipien=
t,=20
please contact the sender by reply email and destroy all copies of the or=
iginal=20
message. </DIV>
<DIV>
<HR>
</DIV>
<P></P>
</body></html>

--_000_5F2C6DA655B36C43B21C7FB179CEC9F4E3F157B9DAHKMAIL02nvidi_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
