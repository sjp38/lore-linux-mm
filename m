Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 2EB146B007E
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 12:45:07 -0500 (EST)
Received: by pbcup15 with SMTP id up15so884891pbc.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 09:45:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F41F1C2.3030908@openvz.org>
References: <20120217092205.GA9462@gmail.com>
	<4F3EB675.9030702@openvz.org>
	<20120220062006.GA5028@gmail.com>
	<4F41F1C2.3030908@openvz.org>
Date: Thu, 8 Mar 2012 01:45:06 +0800
Message-ID: <CANWLp03njY11Swiic7_mv6Gk3C=v4YYe5nLzbAjLH0KftyQftA@mail.gmail.com>
Subject: Re: Fine granularity page reclaim
From: Zheng Liu <gnehzuil.liu@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b2eda4f4e414f04baaab87d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

--047d7b2eda4f4e414f04baaab87d
Content-Type: text/plain; charset=ISO-8859-1

On Monday, February 20, 2012, Konstantin Khlebnikov <khlebnikov@openvz.org>
wrote:
> Zheng Liu wrote:
>>
>> Cc linux-kernel mailing list.
>>
>> On Sat, Feb 18, 2012 at 12:20:05AM +0400, Konstantin Khlebnikov wrote:
>>>
>>> Zheng Liu wrote:
>>>>
>>>> Hi all,
>>>>
>>>> Currently, we encounter a problem about page reclaim. In our product
system,
>>>> there is a lot of applictions that manipulate a number of files. In
these
>>>> files, they can be divided into two categories. One is index file,
another is
>>>> block file. The number of index files is about 15,000, and the number
of
>>>> block files is about 23,000 in a 2TB disk. The application accesses
index
>>>> file using mmap(2), and read/write block file using
pread(2)/pwrite(2). We hope
>>>> to hold index file in memory as much as possible, and it works well in
Redhat
>>>> 2.6.18-164. It is about 60-70% of index files that can be hold in
memory.
>>>> However, it doesn't work well in Redhat 2.6.32-133. I know in 2.6.18
that the
>>>> linux uses an active list and an inactive list to handle page reclaim,
and in
>>>> 2.6.32 that they are divided into anonymous list and file list. So I am
>>>> curious about why most of index files can be hold in 2.6.18? The index
file
>>>> should be replaced because mmap doesn't impact the lru list.
>>>
>>> There was my patch for fixing similar problem with shared/executable
mapped pages
>>> "vmscan: promote shared file mapped pages" commit 34dbc67a644f and
commit c909e99364c
>>> maybe it will help in your case.
>>
>> Hi Konstantin,
>>
>> Thank you for your reply.  I have tested it in upstream kernel.  These
>> patches are useful for multi-processes applications.  But, in our product
>> system, there are some applications that are multi-thread.  So
>> 'references_ptes>  1' cannot help these applications to hold the data in
>> memory.
>
> Ok, what if you mmap you data as executable, just to test.
> Then these pages will be activated after first touch.
> In attachment patch with per-mm flag with the same effect.
>

Hi Konstantin,

Sorry for the delay reply.  Last two weeks I was trying these two solutions
and evaluating the impacts for the performance in our product system.
Good news is that these two solutions both work well. They can keep
mapped files in memory under mult-thread.  But I have a question for
the first solution (map the file with PROT_EXEC flag).  I think this way is
too tricky.  As I said previously, these files that needs to be mapped only
are normal index file, and they shouldn't be mapped with PROT_EXEC flag
from the view of an application programmer.  So actually the key issue is
that we should provide a mechanism, which lets different file sets can be
reclaimed separately.  I am not sure whether this idea is useful or not.  So
any feedbacks are welcomed.:-).  Thank you.

Regards,
Zheng

>>
>> Regards,
>> Zheng
>>
>>>
>>>>
>>>> BTW, I have some problems that need to be discussed.
>>>>
>>>> 1. I want to let index and block files are separately reclaimed. Is
there any
>>>> ways to satisify me in current upstream?
>>>>
>>>> 2. Maybe we can provide a mechansim to let different files to be
mapped into
>>>> differnet nodes. we can provide a ioctl(2) to tell kernel that this
file should
>>>> be mapped into a specific node id. A nid member is added into
addpress_space
>>>> struct. When alloc_page is called, the page can be allocated from that
specific
>>>> node id.
>>>>
>>>> 3. Currently the page can be reclaimed according to pid in memcg. But
it is too
>>>> coarse. I don't know whether memcg could provide a fine granularity
page
>>>> reclaim mechansim. For example, the page is reclaimed according to
inode number.
>>>>
>>>> I don't subscribe this mailing list, So please Cc me. Thank you.
>>>>
>>>> Regards,
>>>> Zheng
>>>>
>>>> --
>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>> see: http://www.linux-mm.org/ .
>>>> Fight unfair telecom internet charges in Canada: sign
http://stopthemeter.ca/
>>>> Don't email:<a href=mailto:"dont@kvack.org">   email@kvack.org</a>
>>>
>
>

--047d7b2eda4f4e414f04baaab87d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br>On Monday, February 20, 2012, Konstantin Khlebnikov &lt;<a href=3D"=
mailto:khlebnikov@openvz.org">khlebnikov@openvz.org</a>&gt; wrote:<br>&gt; =
Zheng Liu wrote:<br>&gt;&gt;<br>&gt;&gt; Cc linux-kernel mailing list.<br>
&gt;&gt;<br>&gt;&gt; On Sat, Feb 18, 2012 at 12:20:05AM +0400, Konstantin K=
hlebnikov wrote:<br>&gt;&gt;&gt;<br>&gt;&gt;&gt; Zheng Liu wrote:<br>&gt;&g=
t;&gt;&gt;<br>&gt;&gt;&gt;&gt; Hi all,<br>&gt;&gt;&gt;&gt;<br>&gt;&gt;&gt;&=
gt; Currently, we encounter a problem about page reclaim. In our product sy=
stem,<br>
&gt;&gt;&gt;&gt; there is a lot of applictions that manipulate a number of =
files. In these<br>&gt;&gt;&gt;&gt; files, they can be divided into two cat=
egories. One is index file, another is<br>&gt;&gt;&gt;&gt; block file. The =
number of index files is about 15,000, and the number of<br>
&gt;&gt;&gt;&gt; block files is about 23,000 in a 2TB disk. The application=
 accesses index<br>&gt;&gt;&gt;&gt; file using mmap(2), and read/write bloc=
k file using pread(2)/pwrite(2). We hope<br>&gt;&gt;&gt;&gt; to hold index =
file in memory as much as possible, and it works well in Redhat<br>
&gt;&gt;&gt;&gt; 2.6.18-164. It is about 60-70% of index files that can be =
hold in memory.<br>&gt;&gt;&gt;&gt; However, it doesn&#39;t work well in Re=
dhat 2.6.32-133. I know in 2.6.18 that the<br>&gt;&gt;&gt;&gt; linux uses a=
n active list and an inactive list to handle page reclaim, and in<br>
&gt;&gt;&gt;&gt; 2.6.32 that they are divided into anonymous list and file =
list. So I am<br>&gt;&gt;&gt;&gt; curious about why most of index files can=
 be hold in 2.6.18? The index file<br>&gt;&gt;&gt;&gt; should be replaced b=
ecause mmap doesn&#39;t impact the lru list.<br>
&gt;&gt;&gt;<br>&gt;&gt;&gt; There was my patch for fixing similar problem =
with shared/executable mapped pages<br>&gt;&gt;&gt; &quot;vmscan: promote s=
hared file mapped pages&quot; commit 34dbc67a644f and commit c909e99364c<br=
>
&gt;&gt;&gt; maybe it will help in your case.<br>&gt;&gt;<br>&gt;&gt; Hi Ko=
nstantin,<br>&gt;&gt;<br>&gt;&gt; Thank you for your reply. =A0I have teste=
d it in upstream kernel. =A0These<br>&gt;&gt; patches are useful for multi-=
processes applications. =A0But, in our product<br>
&gt;&gt; system, there are some applications that are multi-thread. =A0So<b=
r>&gt;&gt; &#39;references_ptes&gt; =A01&#39; cannot help these application=
s to hold the data in<br>&gt;&gt; memory.<br>&gt;<br>&gt; Ok, what if you m=
map you data as executable, just to test.<br>
&gt; Then these pages will be activated after first touch.<br>&gt; In attac=
hment patch with per-mm flag with the same effect.<br>&gt;<br><br>Hi Konsta=
ntin,<br><br>Sorry for the delay reply. =A0Last two weeks I was trying thes=
e two solutions<br>
and evaluating the impacts for the performance in our product system.<br>Go=
od news is that these two solutions both work well. They can keep<br>mapped=
 files in memory under mult-thread. =A0But I have a question for<br>the fir=
st solution (map the file with PROT_EXEC flag). =A0I think this way is<br>
too tricky. =A0As I said previously, these files that needs to be mapped on=
ly<br>are normal index file, and they shouldn&#39;t be mapped with PROT_EXE=
C flag<br>from the view of an application programmer. =A0So actually the ke=
y issue is<br>
that we should provide a mechanism, which lets different file sets can be<b=
r>reclaimed separately. =A0I am not sure whether this idea is useful or not=
. =A0So<br>any feedbacks are welcomed.:-). =A0Thank you.<br><br>Regards,<br=
>Zheng<br>
<br>&gt;&gt;<br>&gt;&gt; Regards,<br>&gt;&gt; Zheng<br>&gt;&gt;<br>&gt;&gt;=
&gt;<br>&gt;&gt;&gt;&gt;<br>&gt;&gt;&gt;&gt; BTW, I have some problems that=
 need to be discussed.<br>&gt;&gt;&gt;&gt;<br>&gt;&gt;&gt;&gt; 1. I want to=
 let index and block files are separately reclaimed. Is there any<br>
&gt;&gt;&gt;&gt; ways to satisify me in current upstream?<br>&gt;&gt;&gt;&g=
t;<br>&gt;&gt;&gt;&gt; 2. Maybe we can provide a mechansim to let different=
 files to be mapped into<br>&gt;&gt;&gt;&gt; differnet nodes. we can provid=
e a ioctl(2) to tell kernel that this file should<br>
&gt;&gt;&gt;&gt; be mapped into a specific node id. A nid member is added i=
nto addpress_space<br>&gt;&gt;&gt;&gt; struct. When alloc_page is called, t=
he page can be allocated from that specific<br>&gt;&gt;&gt;&gt; node id.<br=
>
&gt;&gt;&gt;&gt;<br>&gt;&gt;&gt;&gt; 3. Currently the page can be reclaimed=
 according to pid in memcg. But it is too<br>&gt;&gt;&gt;&gt; coarse. I don=
&#39;t know whether memcg could provide a fine granularity page<br>&gt;&gt;=
&gt;&gt; reclaim mechansim. For example, the page is reclaimed according to=
 inode number.<br>
&gt;&gt;&gt;&gt;<br>&gt;&gt;&gt;&gt; I don&#39;t subscribe this mailing lis=
t, So please Cc me. Thank you.<br>&gt;&gt;&gt;&gt;<br>&gt;&gt;&gt;&gt; Rega=
rds,<br>&gt;&gt;&gt;&gt; Zheng<br>&gt;&gt;&gt;&gt;<br>&gt;&gt;&gt;&gt; --<b=
r>
&gt;&gt;&gt;&gt; To unsubscribe, send a message with &#39;unsubscribe linux=
-mm&#39; in<br>&gt;&gt;&gt;&gt; the body to <a href=3D"mailto:majordomo@kva=
ck.org">majordomo@kvack.org</a>. =A0For more info on Linux MM,<br>&gt;&gt;&=
gt;&gt; see: <a href=3D"http://www.linux-mm.org/">http://www.linux-mm.org/<=
/a> .<br>
&gt;&gt;&gt;&gt; Fight unfair telecom internet charges in Canada: sign <a h=
ref=3D"http://stopthemeter.ca/">http://stopthemeter.ca/</a><br>&gt;&gt;&gt;=
&gt; Don&#39;t email:&lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack=
.org">dont@kvack.org</a>&quot;&gt; =A0 <a href=3D"mailto:email@kvack.org">e=
mail@kvack.org</a>&lt;/a&gt;<br>
&gt;&gt;&gt;<br>&gt;<br>&gt;

--047d7b2eda4f4e414f04baaab87d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
