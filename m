Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC908280267
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 15:04:34 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id n132so322386346oih.1
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 12:04:34 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id 43si10553747oth.121.2016.09.25.12.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 12:04:34 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id r126so185983349oib.0
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 12:04:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzge97L-JLKZq0CTW1wtMOsnt8QzOw3b5qCMmzbKxZ5aw@mail.gmail.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
 <CALXu0Ucx-6PeEk9nTD-4nZvwyVr9LLXcFGFzhctX-ucKfCygGA@mail.gmail.com>
 <CA+55aFyRG=us-EKnomo=QPE0GR1Qdxyw1Ozmuzw0EJcSr7U3hQ@mail.gmail.com>
 <CALXu0UfuwGM+H0YnfSNW6O=hgcUrmws+ihHLVB=OJWOp8YCwgw@mail.gmail.com> <CA+55aFzge97L-JLKZq0CTW1wtMOsnt8QzOw3b5qCMmzbKxZ5aw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 25 Sep 2016 12:04:33 -0700
Message-ID: <CA+55aFxOJTOvxhv+hECHuGV+=xBHMuQitu86J=qBNmMYQ1ACSg@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: multipart/mixed; boundary=001a113d35aa9455c4053d59aec1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@linuxonhyperv.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>

--001a113d35aa9455c4053d59aec1
Content-Type: text/plain; charset=UTF-8

On Sun, Sep 25, 2016 at 11:04 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> The more I look at that particular piece of code, the less I like it. It's
> buggy shit. It needs to be rewritten entirely too actually check for sibling
> entries, not that ad-hoc arithmetic crap.

Here's my attempt at cleaning the mess up.

I'm not claiming it's perfect, but I think it's better. It gets rid of
the ad-hoc arithmetic in radix_tree_descend(), and just makes all that
be inside the is_sibling_entry() logic instead. Which got renamed and
made to actually return the main sibling. So now there is at least
only *one* piece of code that does that range comparison, and I don't
think there is any huge need to explain what's going on, because the
"magic" is unconditional.

Willy?

                 Linus

--001a113d35aa9455c4053d59aec1
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_itizv47j0

IGxpYi9yYWRpeC10cmVlLmMgfCAyMiArKysrKysrKysrKystLS0tLS0tLS0tCiAxIGZpbGUgY2hh
bmdlZCwgMTIgaW5zZXJ0aW9ucygrKSwgMTAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbGli
L3JhZGl4LXRyZWUuYyBiL2xpYi9yYWRpeC10cmVlLmMKaW5kZXggMWI3YmY3MzE0MTQxLi4yMTA3
MDliMDc3NTkgMTAwNjQ0Ci0tLSBhL2xpYi9yYWRpeC10cmVlLmMKKysrIGIvbGliL3JhZGl4LXRy
ZWUuYwpAQCAtNzgsMTggKzc4LDIwIEBAIHN0YXRpYyBpbmxpbmUgdm9pZCAqbm9kZV90b19lbnRy
eSh2b2lkICpwdHIpCiAKICNpZmRlZiBDT05GSUdfUkFESVhfVFJFRV9NVUxUSU9SREVSCiAvKiBT
aWJsaW5nIHNsb3RzIHBvaW50IGRpcmVjdGx5IHRvIGFub3RoZXIgc2xvdCBpbiB0aGUgc2FtZSBu
b2RlICovCi1zdGF0aWMgaW5saW5lIGJvb2wgaXNfc2libGluZ19lbnRyeShzdHJ1Y3QgcmFkaXhf
dHJlZV9ub2RlICpwYXJlbnQsIHZvaWQgKm5vZGUpCitzdGF0aWMgaW5saW5lIHZvaWQgKipnZXRf
c2libGluZ19lbnRyeShzdHJ1Y3QgcmFkaXhfdHJlZV9ub2RlICpwYXJlbnQsIHZvaWQgKm5vZGUp
CiB7Ci0Jdm9pZCAqKnB0ciA9IG5vZGU7Ci0JcmV0dXJuIChwYXJlbnQtPnNsb3RzIDw9IHB0cikg
JiYKLQkJCShwdHIgPCBwYXJlbnQtPnNsb3RzICsgUkFESVhfVFJFRV9NQVBfU0laRSk7CisJdm9p
ZCAqKnB0ciA9ICh2b2lkICoqKSBlbnRyeV90b19ub2RlKG5vZGUpOworCWlmICgocGFyZW50LT5z
bG90cyA8PSBwdHIpICYmIChwdHIgPCBwYXJlbnQtPnNsb3RzICsgUkFESVhfVFJFRV9NQVBfU0la
RSkpCisJCXJldHVybiBwdHI7CisJcmV0dXJuIE5VTEw7CiB9CiAjZWxzZQotc3RhdGljIGlubGlu
ZSBib29sIGlzX3NpYmxpbmdfZW50cnkoc3RydWN0IHJhZGl4X3RyZWVfbm9kZSAqcGFyZW50LCB2
b2lkICpub2RlKQorc3RhdGljIGlubGluZSB2b2lkICoqZ2V0X3NpYmxpbmdfZW50cnkoc3RydWN0
IHJhZGl4X3RyZWVfbm9kZSAqcGFyZW50LCB2b2lkICpub2RlKQogewotCXJldHVybiBmYWxzZTsK
KwlyZXR1cm4gTlVMTDsKIH0KICNlbmRpZgorI2RlZmluZSBpc19zaWJsaW5nX2VudHJ5KHBhcmVu
dCwgbm9kZSkgKGdldF9zaWJsaW5nX2VudHJ5KHBhcmVudCxub2RlKSAhPSBOVUxMKQogCiBzdGF0
aWMgaW5saW5lIHVuc2lnbmVkIGxvbmcgZ2V0X3Nsb3Rfb2Zmc2V0KHN0cnVjdCByYWRpeF90cmVl
X25vZGUgKnBhcmVudCwKIAkJCQkJCSB2b2lkICoqc2xvdCkKQEAgLTEwNSwxMCArMTA3LDEwIEBA
IHN0YXRpYyB1bnNpZ25lZCBpbnQgcmFkaXhfdHJlZV9kZXNjZW5kKHN0cnVjdCByYWRpeF90cmVl
X25vZGUgKnBhcmVudCwKIAogI2lmZGVmIENPTkZJR19SQURJWF9UUkVFX01VTFRJT1JERVIKIAlp
ZiAocmFkaXhfdHJlZV9pc19pbnRlcm5hbF9ub2RlKGVudHJ5KSkgewotCQl1bnNpZ25lZCBsb25n
IHNpYm9mZiA9IGdldF9zbG90X29mZnNldChwYXJlbnQsIGVudHJ5KTsKLQkJaWYgKHNpYm9mZiA8
IFJBRElYX1RSRUVfTUFQX1NJWkUpIHsKLQkJCW9mZnNldCA9IHNpYm9mZjsKLQkJCWVudHJ5ID0g
cmN1X2RlcmVmZXJlbmNlX3JhdyhwYXJlbnQtPnNsb3RzW29mZnNldF0pOworCQl2b2lkICoqc2li
ZW50cnkgPSBnZXRfc2libGluZ19lbnRyeShwYXJlbnQsIGVudHJ5KTsKKwkJaWYgKHNpYmVudHJ5
KSB7CisJCQlvZmZzZXQgPSBnZXRfc2xvdF9vZmZzZXQocGFyZW50LCBzaWJlbnRyeSk7CisJCQll
bnRyeSA9IHJjdV9kZXJlZmVyZW5jZV9yYXcoKnNpYmVudHJ5KTsKIAkJfQogCX0KICNlbmRpZgo=
--001a113d35aa9455c4053d59aec1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
