Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id D1E426B00AA
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 07:30:07 -0400 (EDT)
Received: by wefh52 with SMTP id h52so5737422wef.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 04:30:06 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <1338980115-2394-5-git-send-email-levinsasha928@gmail.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
	<1338980115-2394-5-git-send-email-levinsasha928@gmail.com>
Date: Wed, 6 Jun 2012 07:30:05 -0400
Message-ID: <CAPbh3ruJVJkemK4WqjxQYbXYtD9zdDB3dqrRF916cpw3Ub66ug@mail.gmail.com>
Subject: Re: [PATCH 05/11] mm: frontswap: split frontswap_shrink further to
 eliminate locking games
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Content-Type: multipart/alternative; boundary=0016e6d7e943bdc7d604c1cc1674
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, dan.magenheimer@oracle.com

--0016e6d7e943bdc7d604c1cc1674
Content-Type: text/plain; charset=ISO-8859-1

On Jun 6, 2012 6:55 AM, "Sasha Levin" <levinsasha928@gmail.com> wrote:
>
> Split frontswap_shrink to eliminate the locking issues in the original
code.

Can you describe the locking issue please?
>
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  mm/frontswap.c |   36 +++++++++++++++++++++---------------
>  1 files changed, 21 insertions(+), 15 deletions(-)
>
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index a9b76cb..618ef91 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -244,6 +244,24 @@ static int __frontswap_unuse_pages(unsigned long
total, unsigned long *unused,
>        return ret;
>  }
>
> +static int __frontswap_shrink(unsigned long target_pages,
> +                               unsigned long *pages_to_unuse,
> +                               int *type)
> +{
> +       unsigned long total_pages = 0, total_pages_to_unuse;
> +
> +       lockdep_assert_held(&swap_lock);
> +
> +       total_pages = __frontswap_curr_pages();
> +       if (total_pages <= target_pages) {
> +               /* Nothing to do */
> +               *pages_to_unuse = 0;
> +               return 0;
> +       }
> +       total_pages_to_unuse = total_pages - target_pages;
> +       return __frontswap_unuse_pages(total_pages_to_unuse,
pages_to_unuse, type);
> +}
> +
>  /*
>  * Frontswap, like a true swap device, may unnecessarily retain pages
>  * under certain circumstances; "shrink" frontswap is essentially a
> @@ -254,10 +272,8 @@ static int __frontswap_unuse_pages(unsigned long
total, unsigned long *unused,
>  */
>  void frontswap_shrink(unsigned long target_pages)
>  {
> -       unsigned long total_pages = 0, total_pages_to_unuse;
>        unsigned long pages_to_unuse = 0;
>        int type, ret;
> -       bool locked = false;
>
>        /*
>         * we don't want to hold swap_lock while doing a very
> @@ -265,20 +281,10 @@ void frontswap_shrink(unsigned long target_pages)
>         * so restart scan from swap_list.head each time
>         */
>        spin_lock(&swap_lock);
> -       locked = true;
> -       total_pages = __frontswap_curr_pages();
> -       if (total_pages <= target_pages)
> -               goto out;
> -       total_pages_to_unuse = total_pages - target_pages;
> -       ret = __frontswap_unuse_pages(total_pages_to_unuse,
&pages_to_unuse, &type);
> -       if (ret < 0)
> -               goto out;
> -       locked = false;
> +       ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
>        spin_unlock(&swap_lock);
> -       try_to_unuse(type, true, pages_to_unuse);
> -out:
> -       if (locked)
> -               spin_unlock(&swap_lock);
> +       if (ret == 0 && pages_to_unuse)
> +               try_to_unuse(type, true, pages_to_unuse);
>        return;
>  }
>  EXPORT_SYMBOL(frontswap_shrink);
> --
> 1.7.8.6
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--0016e6d7e943bdc7d604c1cc1674
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p><br>
On Jun 6, 2012 6:55 AM, &quot;Sasha Levin&quot; &lt;<a href=3D"mailto:levin=
sasha928@gmail.com">levinsasha928@gmail.com</a>&gt; wrote:<br>
&gt;<br>
&gt; Split frontswap_shrink to eliminate the locking issues in the original=
 code.</p>
<p>Can you describe the locking issue please?<br>
&gt;<br>
&gt; Signed-off-by: Sasha Levin &lt;<a href=3D"mailto:levinsasha928@gmail.c=
om">levinsasha928@gmail.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0mm/frontswap.c | =A0 36 +++++++++++++++++++++---------------<br>
&gt; =A01 files changed, 21 insertions(+), 15 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/frontswap.c b/mm/frontswap.c<br>
&gt; index a9b76cb..618ef91 100644<br>
&gt; --- a/mm/frontswap.c<br>
&gt; +++ b/mm/frontswap.c<br>
&gt; @@ -244,6 +244,24 @@ static int __frontswap_unuse_pages(unsigned long =
total, unsigned long *unused,<br>
&gt; =A0 =A0 =A0 =A0return ret;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static int __frontswap_shrink(unsigned long target_pages,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned=
 long *pages_to_unuse,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int *typ=
e)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 unsigned long total_pages =3D 0, total_pages_to_unuse;<b=
r>
&gt; +<br>
&gt; + =A0 =A0 =A0 lockdep_assert_held(&amp;swap_lock);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 total_pages =3D __frontswap_curr_pages();<br>
&gt; + =A0 =A0 =A0 if (total_pages &lt;=3D target_pages) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Nothing to do */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *pages_to_unuse =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
&gt; + =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 total_pages_to_unuse =3D total_pages - target_pages;<br>
&gt; + =A0 =A0 =A0 return __frontswap_unuse_pages(total_pages_to_unuse, pag=
es_to_unuse, type);<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0/*<br>
&gt; =A0* Frontswap, like a true swap device, may unnecessarily retain page=
s<br>
&gt; =A0* under certain circumstances; &quot;shrink&quot; frontswap is esse=
ntially a<br>
&gt; @@ -254,10 +272,8 @@ static int __frontswap_unuse_pages(unsigned long =
total, unsigned long *unused,<br>
&gt; =A0*/<br>
&gt; =A0void frontswap_shrink(unsigned long target_pages)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 =A0 unsigned long total_pages =3D 0, total_pages_to_unuse;<b=
r>
&gt; =A0 =A0 =A0 =A0unsigned long pages_to_unuse =3D 0;<br>
&gt; =A0 =A0 =A0 =A0int type, ret;<br>
&gt; - =A0 =A0 =A0 bool locked =3D false;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0/*<br>
&gt; =A0 =A0 =A0 =A0 * we don&#39;t want to hold swap_lock while doing a ve=
ry<br>
&gt; @@ -265,20 +281,10 @@ void frontswap_shrink(unsigned long target_pages=
)<br>
&gt; =A0 =A0 =A0 =A0 * so restart scan from swap_list.head each time<br>
&gt; =A0 =A0 =A0 =A0 */<br>
&gt; =A0 =A0 =A0 =A0spin_lock(&amp;swap_lock);<br>
&gt; - =A0 =A0 =A0 locked =3D true;<br>
&gt; - =A0 =A0 =A0 total_pages =3D __frontswap_curr_pages();<br>
&gt; - =A0 =A0 =A0 if (total_pages &lt;=3D target_pages)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
&gt; - =A0 =A0 =A0 total_pages_to_unuse =3D total_pages - target_pages;<br>
&gt; - =A0 =A0 =A0 ret =3D __frontswap_unuse_pages(total_pages_to_unuse, &a=
mp;pages_to_unuse, &amp;type);<br>
&gt; - =A0 =A0 =A0 if (ret &lt; 0)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
&gt; - =A0 =A0 =A0 locked =3D false;<br>
&gt; + =A0 =A0 =A0 ret =3D __frontswap_shrink(target_pages, &amp;pages_to_u=
nuse, &amp;type);<br>
&gt; =A0 =A0 =A0 =A0spin_unlock(&amp;swap_lock);<br>
&gt; - =A0 =A0 =A0 try_to_unuse(type, true, pages_to_unuse);<br>
&gt; -out:<br>
&gt; - =A0 =A0 =A0 if (locked)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;swap_lock);<br>
&gt; + =A0 =A0 =A0 if (ret =3D=3D 0 &amp;&amp; pages_to_unuse)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 try_to_unuse(type, true, pages_to_unuse)=
;<br>
&gt; =A0 =A0 =A0 =A0return;<br>
&gt; =A0}<br>
&gt; =A0EXPORT_SYMBOL(frontswap_shrink);<br>
&gt; --<br>
&gt; 1.7.8.6<br>
&gt;<br>
&gt; --<br>
&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<=
br>
&gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org=
</a>. =A0For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/">http://www.linux-mm.org/</a>=
 .<br>
&gt; Fight unfair telecom internet charges in Canada: sign <a href=3D"http:=
//stopthemeter.ca/">http://stopthemeter.ca/</a><br>
&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvac=
k.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">emai=
l@kvack.org</a> &lt;/a&gt;<br>
&gt;<br>
</p>

--0016e6d7e943bdc7d604c1cc1674--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
