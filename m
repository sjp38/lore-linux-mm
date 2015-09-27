Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 78E386B0038
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 01:31:54 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so34029915igb.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 22:31:54 -0700 (PDT)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id i10si7637192ioo.115.2015.09.26.22.31.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 22:31:53 -0700 (PDT)
Received: by ioiz6 with SMTP id z6so146178519ioi.2
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 22:31:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
Date: Sun, 27 Sep 2015 07:31:53 +0200
Message-ID: <CAJPN1uvPyZ+hZ64_0ZXU9wPLuAR-qm06GrRmHTjc9+rgiChYDQ@mail.gmail.com>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
From: Jiri Slaby <jirislaby@gmail.com>
Content-Type: multipart/alternative; boundary=001a11402966fe4f180520b3e5c2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: iommu@lists.linux-foundation.org, linux-acpi@vger.kernel.org, linux-bluetooth@vger.kernel.org, linux-scsi@vger.kernel.org, Intel Linux Wireless <ilw@linux.intel.com>, alsa-devel@alsa-project.org, linux-usb@vger.kernel.org, linaro-kernel@lists.linaro.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-edac@vger.kernel.org, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, linux-wireless@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, netdev@vger.kernel.org

--001a11402966fe4f180520b3e5c2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Dne 25. 9. 2015 18:42 napsal u=C5=BEivatel "Viresh Kumar" <
viresh.kumar@linaro.org>:
>
> global_lock is defined as an unsigned long and accessing only its lower
> 32 bits from sysfs is incorrect, as we need to consider other 32 bits
> for big endian 64 bit systems. There are no such platforms yet, but the
> code needs to be robust for such a case.
>
> Fix that by passing a local variable to debugfs_create_bool() and
> assigning its value to global_lock later.

But this has to crash whenever the file is read as val's storage is gone at
that moment already, right?

> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
> ---
> V3->V4:
> - Create a local variable instead of changing type of global_lock
>   (Rafael)
> - Drop the stable tag
> - BCC'd a lot of people (rather than cc'ing them) to make sure
>   - the series reaches them
>   - mailing lists do not block the patchset due to long cc list
>   - and we don't spam the BCC'd people for every reply
> ---
>  drivers/acpi/ec_sys.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/acpi/ec_sys.c b/drivers/acpi/ec_sys.c
> index b4c216bab22b..b44b91331a56 100644
> --- a/drivers/acpi/ec_sys.c
> +++ b/drivers/acpi/ec_sys.c
> @@ -110,6 +110,7 @@ static int acpi_ec_add_debugfs(struct acpi_ec *ec,
unsigned int ec_device_count)
>         struct dentry *dev_dir;
>         char name[64];
>         umode_t mode =3D 0400;
> +       u32 val;
>
>         if (ec_device_count =3D=3D 0) {
>                 acpi_ec_debugfs_dir =3D debugfs_create_dir("ec", NULL);
> @@ -127,10 +128,11 @@ static int acpi_ec_add_debugfs(struct acpi_ec *ec,
unsigned int ec_device_count)
>
>         if (!debugfs_create_x32("gpe", 0444, dev_dir, (u32
*)&first_ec->gpe))
>                 goto error;
> -       if (!debugfs_create_bool("use_global_lock", 0444, dev_dir,
> -                                (u32 *)&first_ec->global_lock))
> +       if (!debugfs_create_bool("use_global_lock", 0444, dev_dir, &val))
>                 goto error;
>
> +       first_ec->global_lock =3D val;
> +
>         if (write_support)
>                 mode =3D 0600;
>         if (!debugfs_create_file("io", mode, dev_dir, ec,
&acpi_ec_io_ops))
> --
> 2.4.0
>

--001a11402966fe4f180520b3e5c2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
Dne 25. 9. 2015 18:42 napsal u=C5=BEivatel &quot;Viresh Kumar&quot; &lt;<a =
href=3D"mailto:viresh.kumar@linaro.org">viresh.kumar@linaro.org</a>&gt;:<br=
>
&gt;<br>
&gt; global_lock is defined as an unsigned long and accessing only its lowe=
r<br>
&gt; 32 bits from sysfs is incorrect, as we need to consider other 32 bits<=
br>
&gt; for big endian 64 bit systems. There are no such platforms yet, but th=
e<br>
&gt; code needs to be robust for such a case.<br>
&gt;<br>
&gt; Fix that by passing a local variable to debugfs_create_bool() and<br>
&gt; assigning its value to global_lock later.</p>
<p dir=3D"ltr">But this has to crash whenever the file is read as val&#39;s=
 storage is gone at that moment already, right?</p>
<p dir=3D"ltr">&gt; Signed-off-by: Viresh Kumar &lt;<a href=3D"mailto:vires=
h.kumar@linaro.org">viresh.kumar@linaro.org</a>&gt;<br>
&gt; ---<br>
&gt; V3-&gt;V4:<br>
&gt; - Create a local variable instead of changing type of global_lock<br>
&gt; =C2=A0 (Rafael)<br>
&gt; - Drop the stable tag<br>
&gt; - BCC&#39;d a lot of people (rather than cc&#39;ing them) to make sure=
<br>
&gt; =C2=A0 - the series reaches them<br>
&gt; =C2=A0 - mailing lists do not block the patchset due to long cc list<b=
r>
&gt; =C2=A0 - and we don&#39;t spam the BCC&#39;d people for every reply<br=
>
&gt; ---<br>
&gt; =C2=A0drivers/acpi/ec_sys.c | 6 ++++--<br>
&gt; =C2=A01 file changed, 4 insertions(+), 2 deletions(-)<br>
&gt;<br>
&gt; diff --git a/drivers/acpi/ec_sys.c b/drivers/acpi/ec_sys.c<br>
&gt; index b4c216bab22b..b44b91331a56 100644<br>
&gt; --- a/drivers/acpi/ec_sys.c<br>
&gt; +++ b/drivers/acpi/ec_sys.c<br>
&gt; @@ -110,6 +110,7 @@ static int acpi_ec_add_debugfs(struct acpi_ec *ec,=
 unsigned int ec_device_count)<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct dentry *dev_dir;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 char name[64];<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 umode_t mode =3D 0400;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0u32 val;<br>
&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ec_device_count =3D=3D 0) {<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 acpi_ec_debugf=
s_dir =3D debugfs_create_dir(&quot;ec&quot;, NULL);<br>
&gt; @@ -127,10 +128,11 @@ static int acpi_ec_add_debugfs(struct acpi_ec *e=
c, unsigned int ec_device_count)<br>
&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!debugfs_create_x32(&quot;gpe&quot;, 0=
444, dev_dir, (u32 *)&amp;first_ec-&gt;gpe))<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto error;<br=
>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!debugfs_create_bool(&quot;use_global_=
lock&quot;, 0444, dev_dir,<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (u32 *)&amp;first_ec-&gt;global_=
lock))<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!debugfs_create_bool(&quot;use_global_=
lock&quot;, 0444, dev_dir, &amp;val))<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto error;<br=
>
&gt;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0first_ec-&gt;global_lock =3D val;<br>
&gt; +<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (write_support)<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mode =3D 0600;=
<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!debugfs_create_file(&quot;io&quot;, m=
ode, dev_dir, ec, &amp;acpi_ec_io_ops))<br>
&gt; --<br>
&gt; 2.4.0<br>
&gt;<br>
</p>

--001a11402966fe4f180520b3e5c2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
