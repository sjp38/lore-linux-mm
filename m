Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 077C58D003B
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 18:19:29 -0400 (EDT)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p2QMItUL014356
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 15:18:55 -0700
Received: by iyf13 with SMTP id 13so3235732iyf.14
        for <linux-mm@kvack.org>; Sat, 26 Mar 2011 15:18:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1103261440160.25375@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger> <20110324142146.GA11682@elte.hu>
 <alpine.DEB.2.00.1103240940570.32226@router.home> <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
 <20110324172653.GA28507@elte.hu> <20110324185258.GA28370@elte.hu>
 <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6>
 <20110324192247.GA5477@elte.hu> <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com>
 <20110326112725.GA28612@elte.hu> <20110326114736.GA8251@elte.hu>
 <1301161507.2979.105.camel@edumazet-laptop> <alpine.DEB.2.00.1103261406420.24195@router.home>
 <alpine.DEB.2.00.1103261428200.25375@router.home> <alpine.DEB.2.00.1103261440160.25375@router.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 26 Mar 2011 15:18:35 -0700
Message-ID: <AANLkTinTzKQkRcE2JvP_BpR0YMj82gppAmNo7RqgftCG@mail.gmail.com>
Subject: Re: [PATCH] slub: Disable the lockless allocator
Content-Type: multipart/mixed; boundary=0015177407b69c6eb6049f6a184f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--0015177407b69c6eb6049f6a184f
Content-Type: text/plain; charset=ISO-8859-1

On Sat, Mar 26, 2011 at 12:49 PM, Christoph Lameter <cl@linux.com> wrote:
> On Sat, 26 Mar 2011, Christoph Lameter wrote:
>
>> Tejun: Whats going on there? I should be getting offsets into the per cpu
>> area and not kernel addresses.
>
> Its a UP kernel running on dual Athlon. So its okay ... Argh.... The
> following patch fixes it by using the fallback code for cmpxchg_double:

Hmm.

Looking closer, I think there are more bugs in that cmpxchg_double thing.

In particular, it doesn't mark memory as changed, so gcc might
miscompile it even on SMP. Also, I think we'd be better off using the
'cmpxchg16b' instruction even on UP, so it's sad to disable it
entirely there.

Wouldn't something like the attached be better?

NOTE! TOTALLY UNTESTED!

                 Linus

--0015177407b69c6eb6049f6a184f
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_glr3oobz0

IGFyY2gveDg2L2luY2x1ZGUvYXNtL3BlcmNwdS5oIHwgICAxMCArKysrKystLS0tCiAxIGZpbGVz
IGNoYW5nZWQsIDYgaW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9h
cmNoL3g4Ni9pbmNsdWRlL2FzbS9wZXJjcHUuaCBiL2FyY2gveDg2L2luY2x1ZGUvYXNtL3BlcmNw
dS5oCmluZGV4IGEwOWUxZjAuLmQ0NzViNDMgMTAwNjQ0Ci0tLSBhL2FyY2gveDg2L2luY2x1ZGUv
YXNtL3BlcmNwdS5oCisrKyBiL2FyY2gveDg2L2luY2x1ZGUvYXNtL3BlcmNwdS5oCkBAIC00NSw3
ICs0NSw3IEBACiAjaW5jbHVkZSA8bGludXgvc3RyaW5naWZ5Lmg+CiAKICNpZmRlZiBDT05GSUdf
U01QCi0jZGVmaW5lIF9fcGVyY3B1X2FyZyh4KQkJIiUlIl9fc3RyaW5naWZ5KF9fcGVyY3B1X3Nl
ZykiOiVQIiAjeAorI2RlZmluZSBfX3BlcmNwdV9wcmVmaXgJCSIlJSJfX3N0cmluZ2lmeShfX3Bl
cmNwdV9zZWcpIjoiCiAjZGVmaW5lIF9fbXlfY3B1X29mZnNldAkJcGVyY3B1X3JlYWQodGhpc19j
cHVfb2ZmKQogCiAvKgpAQCAtNjIsOSArNjIsMTEgQEAKIAkodHlwZW9mKCoocHRyKSkgX19rZXJu
ZWwgX19mb3JjZSAqKXRjcF9wdHJfXzsJXAogfSkKICNlbHNlCi0jZGVmaW5lIF9fcGVyY3B1X2Fy
Zyh4KQkJIiVQIiAjeAorI2RlZmluZSBfX3BlcmNwdV9wcmVmaXgJCSIiCiAjZW5kaWYKIAorI2Rl
ZmluZSBfX3BlcmNwdV9hcmcoeCkJCV9fcGVyY3B1X3ByZWZpeCAiJVAiICN4CisKIC8qCiAgKiBJ
bml0aWFsaXplZCBwb2ludGVycyB0byBwZXItY3B1IHZhcmlhYmxlcyBuZWVkZWQgZm9yIHRoZSBi
b290CiAgKiBwcm9jZXNzb3IgbmVlZCB0byB1c2UgdGhlc2UgbWFjcm9zIHRvIGdldCB0aGUgcHJv
cGVyIGFkZHJlc3MKQEAgLTUxNiwxMSArNTE4LDExIEBAIGRvIHsJCQkJCQkJCQlcCiAJdHlwZW9m
KG8yKSBfX24yID0gbjI7CQkJCQkJXAogCXR5cGVvZihvMikgX19kdW1teTsJCQkJCQlcCiAJYWx0
ZXJuYXRpdmVfaW8oImNhbGwgdGhpc19jcHVfY21weGNoZzE2Yl9lbXVcblx0IiBQNl9OT1A0LAlc
Ci0JCSAgICAgICAiY21weGNoZzE2YiAlJWdzOiglJXJzaSlcblx0c2V0eiAlMFxuXHQiLAlcCisJ
CSAgICAgICAiY21weGNoZzE2YiAiIF9fcGVyY3B1X3ByZWZpeCAiKCUlcnNpKVxuXHRzZXR6ICUw
XG5cdCIsCVwKIAkJICAgICAgIFg4Nl9GRUFUVVJFX0NYMTYsCQkJCVwKIAkJICAgICAgIEFTTV9P
VVRQVVQyKCI9YSIoX19yZXQpLCAiPWQiKF9fZHVtbXkpKSwJCVwKIAkJICAgICAgICJTIiAoJnBj
cDEpLCAiYiIoX19uMSksICJjIihfX24yKSwJCVwKLQkJICAgICAgICJhIihfX28xKSwgImQiKF9f
bzIpKTsJCQkJXAorCQkgICAgICAgImEiKF9fbzEpLCAiZCIoX19vMikgOiAibWVtb3J5Iik7CQlc
CiAJX19yZXQ7CQkJCQkJCQlcCiB9KQogCg==
--0015177407b69c6eb6049f6a184f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
