Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f54.google.com (mail-lf0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id A6F2B6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:08:26 -0500 (EST)
Received: by lfcy184 with SMTP id y184so42063138lfc.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 01:08:25 -0800 (PST)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id d5si16618041lbv.99.2015.12.14.01.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 01:08:24 -0800 (PST)
Received: by lfed137 with SMTP id d137so64708905lfe.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 01:08:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1449124550-7781-1-git-send-email-Janne.Karhunen@gmail.com>
References: <1449124550-7781-1-git-send-email-Janne.Karhunen@gmail.com>
Date: Mon, 14 Dec 2015 11:08:24 +0200
Message-ID: <CAE=Ncra=v0fqTVm7r0GyGBDgCHqxFzVYQep5jF6-w_JegGTbqQ@mail.gmail.com>
Subject: Re: [PATCH] Introduce a recovery= command line option.
From: Janne Karhunen <janne.karhunen@gmail.com>
Content-Type: multipart/alternative; boundary=001a113f232cf1b7da0526d8035f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Janne Karhunen <Janne.Karhunen@gmail.com>, akpm <akpm@linux-foundation.org>

--001a113f232cf1b7da0526d8035f
Content-Type: text/plain; charset=UTF-8

Hi,

Any comments on this? It would help my life considerably as I have to deal
with multiple bootloaders and royally hate initrds.


--
Janne

On Thu, Dec 3, 2015 at 8:35 AM, Janne Karhunen <Janne.Karhunen@gmail.com>
wrote:

> Recovery option can be used to define a secondary rootfs
> in case mounting of the primary root fails. While it has
> been possible to solve the issue via bootloader and/or
> initrd means, this solution is suitable for systems that
> want to stay bootloader agnostic and operate without an
> initrd.
>
> Signed-off-by: Janne Karhunen <Janne.Karhunen@gmail.com>
> ---
>  Documentation/kernel-parameters.txt |  3 ++
>  init/do_mounts.c                    | 64
> +++++++++++++++++++++++++++++--------
>  2 files changed, 54 insertions(+), 13 deletions(-)
>
> diff --git a/Documentation/kernel-parameters.txt
> b/Documentation/kernel-parameters.txt
> index 742f69d..0d65a63 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -3390,6 +3390,9 @@ bytes respectively. Such letter suffixes can also be
> entirely omitted.
>                 nocompress      Don't compress/decompress hibernation
> images.
>                 no              Disable hibernation and resume.
>
> +       recovery=       [KNL] Recovery root filesystem. This partition is
> attempted as
> +                       root in case default root filesystem does not
> mount.
> +
>         retain_initrd   [RAM] Keep initrd memory after extraction
>
>         rfkill.default_state=
> diff --git a/init/do_mounts.c b/init/do_mounts.c
> index dea5de9..994b2e5 100644
> --- a/init/do_mounts.c
> +++ b/init/do_mounts.c
> @@ -39,8 +39,11 @@ int __initdata rd_doload;    /* 1 = load RAM disk, 0 =
> don't load */
>
>  int root_mountflags = MS_RDONLY | MS_SILENT;
>  static char * __initdata root_device_name;
> +static char * __initdata recovery_device_name;
>  static char __initdata saved_root_name[64];
> +static char __initdata saved_recovery_name[64];
>  static int root_wait;
> +static int recovery_attempt;
>
>  dev_t ROOT_DEV;
>
> @@ -298,6 +301,15 @@ static int __init root_dev_setup(char *line)
>
>  __setup("root=", root_dev_setup);
>
> +static int __init recovery_setup(char *line)
> +{
> +       strlcpy(saved_recovery_name, line, sizeof(saved_recovery_name));
> +       recovery_attempt = 1;
> +       return 1;
> +}
> +
> +__setup("recovery=", recovery_setup);
> +
>  static int __init rootwait_setup(char *str)
>  {
>         if (*str)
> @@ -384,6 +396,7 @@ void __init mount_block_root(char *name, int flags)
>                                         __GFP_NOTRACK_FALSE_POSITIVE);
>         char *fs_names = page_address(page);
>         char *p;
> +       int err;
>  #ifdef CONFIG_BLOCK
>         char b[BDEVNAME_SIZE];
>  #else
> @@ -393,7 +406,7 @@ void __init mount_block_root(char *name, int flags)
>         get_fs_names(fs_names);
>  retry:
>         for (p = fs_names; *p; p += strlen(p)+1) {
> -               int err = do_mount_root(name, p, flags, root_mount_data);
> +               err = do_mount_root(name, p, flags, root_mount_data);
>                 switch (err) {
>                         case 0:
>                                 goto out;
> @@ -401,7 +414,33 @@ retry:
>                         case -EINVAL:
>                                 continue;
>                 }
> -               /*
> +               if (!(flags & MS_RDONLY)) {
> +                       pr_warn("Retrying rootfs mount as read-only.\n");
> +                       flags |= MS_RDONLY;
> +                       goto retry;
> +               }
> +               if (recovery_device_name && recovery_attempt) {
> +                       recovery_attempt = 0;
> +
> +                       ROOT_DEV = name_to_dev_t(recovery_device_name);
> +                       if (strncmp(recovery_device_name, "/dev/", 5) == 0)
> +                               recovery_device_name += 5;
> +
> +                       pr_warn("Unable to mount rootfs at %s, error
> %d.\n",
> +                               root_device_name, err);
> +                       pr_warn("Attempting %s for recovery as
> requested.\n",
> +                               recovery_device_name);
> +
> +                       err = create_dev("/dev/root", ROOT_DEV);
> +                       if (err < 0)
> +                               pr_emerg("Failed to re-create /dev/root:
> %d\n",
> +                                       err);
> +
> +                       root_device_name = recovery_device_name;
> +                       goto retry;
> +               }
> +
> +               /*
>                  * Allow the user to distinguish between failed sys_open
>                  * and bad superblock on root device.
>                  * and give them a list of the available devices
> @@ -409,28 +448,24 @@ retry:
>  #ifdef CONFIG_BLOCK
>                 __bdevname(ROOT_DEV, b);
>  #endif
> -               printk("VFS: Cannot open root device \"%s\" or %s: error
> %d\n",
> +               pr_emerg("VFS: Cannot open root device \"%s\" or %s: error
> %d\n",
>                                 root_device_name, b, err);
> -               printk("Please append a correct \"root=\" boot option;
> here are the available partitions:\n");
> +               pr_emerg("Please append a correct \"root=\" boot option;
> here are the available partitions:\n");
>
>                 printk_all_partitions();
>  #ifdef CONFIG_DEBUG_BLOCK_EXT_DEVT
> -               printk("DEBUG_BLOCK_EXT_DEVT is enabled, you need to
> specify "
> +               pr_emerg("DEBUG_BLOCK_EXT_DEVT is enabled, you need to
> specify "
>                        "explicit textual name for \"root=\" boot
> option.\n");
>  #endif
>                 panic("VFS: Unable to mount root fs on %s", b);
>         }
> -       if (!(flags & MS_RDONLY)) {
> -               flags |= MS_RDONLY;
> -               goto retry;
> -       }
>
> -       printk("List of all partitions:\n");
> +       pr_emerg("List of all partitions:\n");
>         printk_all_partitions();
> -       printk("No filesystem could mount root, tried: ");
> +       pr_emerg("No filesystem could mount root, tried: ");
>         for (p = fs_names; *p; p += strlen(p)+1)
> -               printk(" %s", p);
> -       printk("\n");
> +               pr_emerg(" %s", p);
> +       pr_emerg("\n");
>  #ifdef CONFIG_BLOCK
>         __bdevname(ROOT_DEV, b);
>  #endif
> @@ -567,6 +602,9 @@ void __init prepare_namespace(void)
>
>         md_run_setup();
>
> +       if (saved_recovery_name[0])
> +               recovery_device_name = saved_recovery_name;
> +
>         if (saved_root_name[0]) {
>                 root_device_name = saved_root_name;
>                 if (!strncmp(root_device_name, "mtd", 3) ||
> --
> 1.9.1
>
>

--001a113f232cf1b7da0526d8035f
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div>Hi,<br><br></div>Any comments on this? It would =
help my life considerably as I have to deal with multiple bootloaders and r=
oyally hate initrds.<br><br><br>--<br></div>Janne<br></div><div class=3D"gm=
ail_extra"><br><div class=3D"gmail_quote">On Thu, Dec 3, 2015 at 8:35 AM, J=
anne Karhunen <span dir=3D"ltr">&lt;<a href=3D"mailto:Janne.Karhunen@gmail.=
com" target=3D"_blank">Janne.Karhunen@gmail.com</a>&gt;</span> wrote:<br><b=
lockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px =
#ccc solid;padding-left:1ex">Recovery option can be used to define a second=
ary rootfs<br>
in case mounting of the primary root fails. While it has<br>
been possible to solve the issue via bootloader and/or<br>
initrd means, this solution is suitable for systems that<br>
want to stay bootloader agnostic and operate without an<br>
initrd.<br>
<br>
Signed-off-by: Janne Karhunen &lt;<a href=3D"mailto:Janne.Karhunen@gmail.co=
m">Janne.Karhunen@gmail.com</a>&gt;<br>
---<br>
=C2=A0Documentation/kernel-parameters.txt |=C2=A0 3 ++<br>
=C2=A0init/do_mounts.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | 64 +++++++++++++++++++++++++++++--------<br>
=C2=A02 files changed, 54 insertions(+), 13 deletions(-)<br>
<br>
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-par=
ameters.txt<br>
index 742f69d..0d65a63 100644<br>
--- a/Documentation/kernel-parameters.txt<br>
+++ b/Documentation/kernel-parameters.txt<br>
@@ -3390,6 +3390,9 @@ bytes respectively. Such letter suffixes can also be =
entirely omitted.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nocompress=C2=A0 =
=C2=A0 =C2=A0 Don&#39;t compress/decompress hibernation images.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 no=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Disable hibernation and resume.<br>
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0recovery=3D=C2=A0 =C2=A0 =C2=A0 =C2=A0[KNL] Rec=
overy root filesystem. This partition is attempted as<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0root in case default root filesystem does not mount.<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 retain_initrd=C2=A0 =C2=A0[RAM] Keep initrd mem=
ory after extraction<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 rfkill.default_state=3D<br>
diff --git a/init/do_mounts.c b/init/do_mounts.c<br>
index dea5de9..994b2e5 100644<br>
--- a/init/do_mounts.c<br>
+++ b/init/do_mounts.c<br>
@@ -39,8 +39,11 @@ int __initdata rd_doload;=C2=A0 =C2=A0 /* 1 =3D load RAM=
 disk, 0 =3D don&#39;t load */<br>
<br>
=C2=A0int root_mountflags =3D MS_RDONLY | MS_SILENT;<br>
=C2=A0static char * __initdata root_device_name;<br>
+static char * __initdata recovery_device_name;<br>
=C2=A0static char __initdata saved_root_name[64];<br>
+static char __initdata saved_recovery_name[64];<br>
=C2=A0static int root_wait;<br>
+static int recovery_attempt;<br>
<br>
=C2=A0dev_t ROOT_DEV;<br>
<br>
@@ -298,6 +301,15 @@ static int __init root_dev_setup(char *line)<br>
<br>
=C2=A0__setup(&quot;root=3D&quot;, root_dev_setup);<br>
<br>
+static int __init recovery_setup(char *line)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0strlcpy(saved_recovery_name, line, sizeof(saved=
_recovery_name));<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0recovery_attempt =3D 1;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;<br>
+}<br>
+<br>
+__setup(&quot;recovery=3D&quot;, recovery_setup);<br>
+<br>
=C2=A0static int __init rootwait_setup(char *str)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (*str)<br>
@@ -384,6 +396,7 @@ void __init mount_block_root(char *name, int flags)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __GFP_NO=
TRACK_FALSE_POSITIVE);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 char *fs_names =3D page_address(page);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 char *p;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0int err;<br>
=C2=A0#ifdef CONFIG_BLOCK<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 char b[BDEVNAME_SIZE];<br>
=C2=A0#else<br>
@@ -393,7 +406,7 @@ void __init mount_block_root(char *name, int flags)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 get_fs_names(fs_names);<br>
=C2=A0retry:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 for (p =3D fs_names; *p; p +=3D strlen(p)+1) {<=
br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int err =3D do_moun=
t_root(name, p, flags, root_mount_data);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D do_mount_ro=
ot(name, p, flags, root_mount_data);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 switch (err) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 case 0:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;<br>
@@ -401,7 +414,33 @@ retry:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 case -EINVAL:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(flags &amp; M=
S_RDONLY)) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0pr_warn(&quot;Retrying rootfs mount as read-only.\n&quot;);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0flags |=3D MS_RDONLY;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto retry;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (recovery_device=
_name &amp;&amp; recovery_attempt) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0recovery_attempt =3D 0;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0ROOT_DEV =3D name_to_dev_t(recovery_device_name);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (strncmp(recovery_device_name, &quot;/dev/&quot;, 5) =3D=3D 0)=
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0recovery_device_name +=3D 5;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0pr_warn(&quot;Unable to mount rootfs at %s, error %d.\n&quot;,<br=
>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0root_device_name, err);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0pr_warn(&quot;Attempting %s for recovery as requested.\n&quot;,<b=
r>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0recovery_device_name);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0err =3D create_dev(&quot;/dev/root&quot;, ROOT_DEV);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (err &lt; 0)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_emerg(&quot;Failed to re-create /d=
ev/root: %d\n&quot;,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0err);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0root_device_name =3D recovery_device_name;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto retry;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Allow the u=
ser to distinguish between failed sys_open<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* and bad sup=
erblock on root device.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* and give th=
em a list of the available devices<br>
@@ -409,28 +448,24 @@ retry:<br>
=C2=A0#ifdef CONFIG_BLOCK<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __bdevname(ROOT_DEV=
, b);<br>
=C2=A0#endif<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(&quot;VFS: C=
annot open root device \&quot;%s\&quot; or %s: error %d\n&quot;,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_emerg(&quot;VFS:=
 Cannot open root device \&quot;%s\&quot; or %s: error %d\n&quot;,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 root_device_name, b, err);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(&quot;Please=
 append a correct \&quot;root=3D\&quot; boot option; here are the available=
 partitions:\n&quot;);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_emerg(&quot;Plea=
se append a correct \&quot;root=3D\&quot; boot option; here are the availab=
le partitions:\n&quot;);<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk_all_partitio=
ns();<br>
=C2=A0#ifdef CONFIG_DEBUG_BLOCK_EXT_DEVT<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(&quot;DEBUG_=
BLOCK_EXT_DEVT is enabled, you need to specify &quot;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_emerg(&quot;DEBU=
G_BLOCK_EXT_DEVT is enabled, you need to specify &quot;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0&quot;explicit textual name for \&quot;root=3D\&quot; boot option=
.\n&quot;);<br>
=C2=A0#endif<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 panic(&quot;VFS: Un=
able to mount root fs on %s&quot;, b);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(flags &amp; MS_RDONLY)) {<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0flags |=3D MS_RDONL=
Y;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto retry;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0printk(&quot;List of all partitions:\n&quot;);<=
br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0pr_emerg(&quot;List of all partitions:\n&quot;)=
;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 printk_all_partitions();<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0printk(&quot;No filesystem could mount root, tr=
ied: &quot;);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0pr_emerg(&quot;No filesystem could mount root, =
tried: &quot;);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 for (p =3D fs_names; *p; p +=3D strlen(p)+1)<br=
>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(&quot; %s&qu=
ot;, p);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0printk(&quot;\n&quot;);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_emerg(&quot; %s&=
quot;, p);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0pr_emerg(&quot;\n&quot;);<br>
=C2=A0#ifdef CONFIG_BLOCK<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __bdevname(ROOT_DEV, b);<br>
=C2=A0#endif<br>
@@ -567,6 +602,9 @@ void __init prepare_namespace(void)<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 md_run_setup();<br>
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (saved_recovery_name[0])<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0recovery_device_nam=
e =3D saved_recovery_name;<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (saved_root_name[0]) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 root_device_name =
=3D saved_root_name;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!strncmp(root_d=
evice_name, &quot;mtd&quot;, 3) ||<br>
<span class=3D"HOEnZb"><font color=3D"#888888">--<br>
1.9.1<br>
<br>
</font></span></blockquote></div><br></div>

--001a113f232cf1b7da0526d8035f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
