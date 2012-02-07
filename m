Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id BB8B86B13F2
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 00:46:43 -0500 (EST)
Received: by lbbgg6 with SMTP id gg6so1902838lbb.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 21:46:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG4AFWZGr8SQF0rV+iys04HWmQ5WEGvXNcSZ9qJ7Jj9+FRbjCg@mail.gmail.com>
References: <CAG4AFWaXVEHP+YikRSyt8ky9XsiBnwQ3O94Bgc7-b7nYL_2PZQ@mail.gmail.com>
	<CANAOKxs8j2T2b0tKssFX9NeC1wyMqjLMQmgmRwMs9qvokYcW2w@mail.gmail.com>
	<CAG4AFWZGr8SQF0rV+iys04HWmQ5WEGvXNcSZ9qJ7Jj9+FRbjCg@mail.gmail.com>
Date: Mon, 6 Feb 2012 23:46:41 -0600
Message-ID: <CANAOKxsFYCW7EzrbNn4jc3wOq6dmDE-pnpn0khxvb4C0iP3DtA@mail.gmail.com>
Subject: Re: Strange finding about kernel samepage merging
From: fluxion <flukshun@gmail.com>
Content-Type: multipart/alternative; boundary=e0cb4efe2888adb99304b8594dc0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jidong Xiao <jidong.xiao@gmail.com>
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org

--e0cb4efe2888adb99304b8594dc0
Content-Type: text/plain; charset=ISO-8859-1

On Feb 6, 2012 10:14 PM, "Jidong Xiao" <jidong.xiao@gmail.com> wrote:
>
> On Mon, Feb 6, 2012 at 10:35 PM, Michael Roth <mdroth@linux.vnet.ibm.com>
wrote:
> > My guess is you end up with 2 copies of each page on the guest: the
copy in
> > the guest's page cache, and the copy in the buffer you allocated. From
the
> > perspective of the host this all looks like anonymous memory, so ksm
merges
> > the pages.
>
> Yes, the result definitely shows that there two copies. But I don't
> understand why there would be two copies. So whenever you allocate
> memory in a guest OS, you will always create two copies of the same
> memory?

Well, not just guests, hosts as well. Most operating systems will, by
default, cache the data read from disks in memory to speed up subsequent
access. In your case you're also creating a copy by allocating a second
buffer and storing the data there as well.

Ksm only merges anonymous pages, not disk/page cache, but since your
guest's pagecache looks like anonymous memory to the host, ksm is able to
merge the dupes.

>
> An interesting thing is, if I replace the posix_memalign() function
> with the malloc() function (See the original program, the commented
> line.) there would be only one copy, i.e., no merging happens,
> however, since I need to have some page-aligned memory, that's why I
> use posix_memalign().

Yup, ksm can only detect duplicate pages, so if your buffer isn't page
aligned it's unable to merge with the copy in the guest's page cache

>
> Regards
> Jidong
>

--e0cb4efe2888adb99304b8594dc0
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p><br>
On Feb 6, 2012 10:14 PM, &quot;Jidong Xiao&quot; &lt;<a href=3D"mailto:jido=
ng.xiao@gmail.com">jidong.xiao@gmail.com</a>&gt; wrote:<br>
&gt;<br>
&gt; On Mon, Feb 6, 2012 at 10:35 PM, Michael Roth &lt;<a href=3D"mailto:md=
roth@linux.vnet.ibm.com">mdroth@linux.vnet.ibm.com</a>&gt; wrote:<br>
&gt; &gt; My guess is you end up with 2 copies of each page on the guest: t=
he copy in<br>
&gt; &gt; the guest&#39;s page cache, and the copy in the buffer you alloca=
ted. From the<br>
&gt; &gt; perspective of the host this all looks like anonymous memory, so =
ksm merges<br>
&gt; &gt; the pages.<br>
&gt;<br>
&gt; Yes, the result definitely shows that there two copies. But I don&#39;=
t<br>
&gt; understand why there would be two copies. So whenever you allocate<br>
&gt; memory in a guest OS, you will always create two copies of the same<br=
>
&gt; memory?</p>
<p>Well, not just guests, hosts as well. Most operating systems will, by de=
fault, cache the data read from disks in memory to speed up subsequent acce=
ss. In your case you&#39;re also creating a copy by allocating a second buf=
fer and storing the data there as well.</p>

<p>Ksm only merges anonymous pages, not disk/page cache, but since your gue=
st&#39;s pagecache looks like anonymous memory to the host, ksm is able to =
merge the dupes.</p>
<p>&gt;<br>
&gt; An interesting thing is, if I replace the posix_memalign() function<br=
>
&gt; with the malloc() function (See the original program, the commented<br=
>
&gt; line.) there would be only one copy, i.e., no merging happens,<br>
&gt; however, since I need to have some page-aligned memory, that&#39;s why=
 I<br>
&gt; use posix_memalign().</p>
<p>Yup, ksm can only detect duplicate pages, so if your buffer isn&#39;t pa=
ge aligned it&#39;s unable to merge with the copy in the guest&#39;s page c=
ache</p>
<p>&gt;<br>
&gt; Regards<br>
&gt; Jidong<br>
&gt;<br>
</p>

--e0cb4efe2888adb99304b8594dc0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
