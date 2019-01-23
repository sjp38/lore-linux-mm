Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA468E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:22:02 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v2so1557065plg.6
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:22:02 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j3si18527568plk.199.2019.01.23.06.22.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 06:22:01 -0800 (PST)
From: Jani Nikula <jani.nikula@linux.intel.com>
Subject: Re: [Intel-gfx] [PATCH 1/3] treewide: Lift switch variables out of switches
In-Reply-To: <874l9z31c5.fsf@intel.com>
References: <20190123110349.35882-1-keescook@chromium.org> <20190123110349.35882-2-keescook@chromium.org> <20190123115829.GA31385@kroah.com> <874l9z31c5.fsf@intel.com>
Date: Wed, 23 Jan 2019 16:23:39 +0200
Message-ID: <871s53311w.fsf@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>
Cc: dev@openvswitch.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, netdev@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, intel-wired-lan@lists.osuosl.org, linux-fsdevel@vger.kernel.org, xen-devel@lists.xenproject.org, Laura Abbott <labbott@redhat.com>, linux-kbuild@vger.kernel.org, Alexander Popov <alex.popov@linux.com>

On Wed, 23 Jan 2019, Jani Nikula <jani.nikula@linux.intel.com> wrote:
> On Wed, 23 Jan 2019, Greg KH <gregkh@linuxfoundation.org> wrote:
>> On Wed, Jan 23, 2019 at 03:03:47AM -0800, Kees Cook wrote:
>>> Variables declared in a switch statement before any case statements
>>> cannot be initialized, so move all instances out of the switches.
>>> After this, future always-initialized stack variables will work
>>> and not throw warnings like this:
>>>=20
>>> fs/fcntl.c: In function =E2=80=98send_sigio_to_task=E2=80=99:
>>> fs/fcntl.c:738:13: warning: statement will never be executed [-Wswitch-=
unreachable]
>>>    siginfo_t si;
>>>              ^~
>>
>> That's a pain, so this means we can't have any new variables in { }
>> scope except for at the top of a function?
>>
>> That's going to be a hard thing to keep from happening over time, as
>> this is valid C :(
>
> Not all valid C is meant to be used! ;)
>
> Anyway, I think you're mistaking the limitation to arbitrary blocks
> while it's only about the switch block IIUC.
>
> Can't have:
>
> 	switch (i) {
> 		int j;
> 	case 0:
>         	/* ... */
> 	}
>
> because it can't be turned into:
>
> 	switch (i) {
> 		int j =3D 0; /* not valid C */
> 	case 0:
>         	/* ... */
> 	}
>
> but can have e.g.:
>
> 	switch (i) {
> 	case 0:
> 		{
> 			int j =3D 0;
> 	        	/* ... */
> 		}
> 	}
>
> I think Kees' approach of moving such variable declarations to the
> enclosing block scope is better than adding another nesting block.

PS. The patch is

Reviewed-by: Jani Nikula <jani.nikula@intel.com>

and the drivers/gpu/drm/i915/* parts are

Acked-by: Jani Nikula <jani.nikula@intel.com>

for merging via whichever tree is appropriate. (There'll be minor
conflicts with in-flight work in our -next tree, but no biggie.)


--=20
Jani Nikula, Intel Open Source Graphics Center
