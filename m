Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B0D5C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 22:35:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 074CE20643
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 22:35:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="GwXzw7uz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 074CE20643
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75D508E000A; Mon, 25 Feb 2019 17:35:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E4938E0005; Mon, 25 Feb 2019 17:35:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AEB08E000A; Mon, 25 Feb 2019 17:35:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBCE78E0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 17:35:10 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id d8so1735136lja.5
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:35:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=10FxPzwQCwaRNmZBCE5TERSl05BGdxracTAlmOVTnMk=;
        b=cmyKxn1AslQS0cpp9ppL/NWaGAvPKnCRgZSU0L5j+tz2ojfVw0nD5V4sBBEaU3RyWt
         n6spGeBMJJ0HBrm5BwW3sH0ipQUqsHF/youAqWyd8qTuFxXsLfqe8tGHuIxWbHK3qaBA
         gQgRJgH1AaI6dhX+0Pxdjkg7bCLWTu4ioKWnLmZZFTnNmwm2kaPpmnexUtsiRkMDc9NV
         3UB4ZgpsAZT0cHXgGsvdjf8KcRcU9J2/w+2BI/SztJsLYX29lRLz72vxfyoiL6cfn6NG
         IBc3XUplvDT3jdKOkYD4gDsbDnu3nQrdBSS2ummDd8XtN/eI5AR54pOHzuAsupJJCink
         j2+A==
X-Gm-Message-State: AHQUAubhlddQncfxrHpxOGk8sHxH03V5Cb3/TPDLZH7lgG7dvK412WFy
	5PURfLt1n9Fj1+IQnVZca3VC9Qv+D++xGPlQGFYQUm4ZyQXos2Dgkag5kEv+G1KpcEpTn77Pfou
	LpiPcGc2FS50muE3rHUmWUl0t/Li1Ub7+P2FyUVW+4MyZ2uQK4Mm8gQ15rl8MZuypuxHrW9iO4K
	2LZzOSSHUOgAt9AAYHuTX7la4i9N0hlEMY+nY1onqJSr8LeGz8xcBADemC4a08mPYjfuKPRJdP1
	Gbq0i7SHKdDlPnkgAwt64xHeBzcHOVrONip4uUZ9JjJ1wlYp0uuxElPhYYEd8PMCh74zPGO1jAM
	HyqbrYHWA7aJmJQFLIaFmBHWXecM9PxVw+iRUewsSTHQ65436a8yJKUeEfyv4ND99jmYG1tPiRb
	v
X-Received: by 2002:ac2:4291:: with SMTP id m17mr11162115lfh.20.1551134109950;
        Mon, 25 Feb 2019 14:35:09 -0800 (PST)
X-Received: by 2002:ac2:4291:: with SMTP id m17mr11162089lfh.20.1551134108662;
        Mon, 25 Feb 2019 14:35:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551134108; cv=none;
        d=google.com; s=arc-20160816;
        b=cIU1EQM5H/Xxo8jQedwlWw9GuUdRcC7XxUkB3wWBW39YgwO2SQUCzjUKE2jj66S6NC
         yhO792z3s2EN2SqSmw4/5zSecW/f1YrXUcbowHwS1ZOV0EFhpB4CaQT51bUzleLTtE8u
         wwwZSd/ARAET8ElERnlRMu3jHnh+zpq6sBdl7OyhY4OJIfrJNTPV2jOdGtIG/0+phGQP
         Frd1zGeq+ih/h2JPyFlPr9UGp5qnWWtSBY6vb0GAjbJ2Tx6r1CqnAZfrkEpqoxlR0jHh
         pX/4egIxMBszkOUy/TbfAiG641OhEIyJ+S5iRjXPn0RkcLwfzy58WHdiyY9f+MPKUdwt
         NdbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=10FxPzwQCwaRNmZBCE5TERSl05BGdxracTAlmOVTnMk=;
        b=MaAAj72ozz2yYjGj5OIQjTd6E+yetst4sf8/2ZrEjnjU+HyyiPQMBwE08DWDLvvTcX
         BPvL+oybMkczPUcRlqpCtcMZbsvl27kvmAGUnXWm6qHqNqsGy1PswbX0ejAIyxKAJvIY
         Kl1WAg2HDDl9IqY7YvoQgl7CSFxqOGjqYaove/CitN6X89RfXfx+IachoUkhqVIVbUuf
         6grQ662R674ppXHbDBEo/EQlN+Ojy6VUPFuikHHS/G2pQs68i7TFMbm7ljDIZQC26mUD
         pCZwbpTWM9QLxwudp+RY2TJUo8stXuDuY8eaPLaKtzvDNfbPy30ZuOZEhUGNFxR+G0Ef
         Pwlw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=GwXzw7uz;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p70sor5911751ljb.4.2019.02.25.14.35.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 14:35:08 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=GwXzw7uz;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=10FxPzwQCwaRNmZBCE5TERSl05BGdxracTAlmOVTnMk=;
        b=GwXzw7uz50GyEJOgXRBmQNvy9n/EkevMtfkKE1TOppZpk86TZGZs02JRG4gAU63ozw
         vHFJfB/Fv2rf95gccgoCS8l4SJi2cDJP8DcI+0rN6PHQUYqyyhp+2uATQZEL9EnyH/rk
         wQtqykh+sZec7f8oe1IeBJ4R+3Q5Jv5bwzhkE=
X-Google-Smtp-Source: AHgI3IYCkhdvfs7b9nOD2516e8nTWO+2pZPjfCpsgUBg9X5QRD6u6Dn/ltGlJ8YOwhpQRlIxxSGTbA==
X-Received: by 2002:a2e:890b:: with SMTP id d11mr12072109lji.174.1551134107406;
        Mon, 25 Feb 2019 14:35:07 -0800 (PST)
Received: from mail-lj1-f176.google.com (mail-lj1-f176.google.com. [209.85.208.176])
        by smtp.gmail.com with ESMTPSA id c186sm1074653lfd.19.2019.02.25.14.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 14:35:04 -0800 (PST)
Received: by mail-lj1-f176.google.com with SMTP id j19so8952347ljg.5
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:35:04 -0800 (PST)
X-Received: by 2002:a2e:7a03:: with SMTP id v3mr11328630ljc.22.1551134103662;
 Mon, 25 Feb 2019 14:35:03 -0800 (PST)
MIME-Version: 1.0
References: <20190221222123.GC6474@magnolia> <alpine.LSU.2.11.1902222222570.1594@eggly.anvils>
 <CAHk-=wgO3MPjPpf_ARyW6zpwwPZtxXYQgMLbmj2bnbOLnR+6Cg@mail.gmail.com> <alpine.LSU.2.11.1902251214220.8973@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1902251214220.8973@eggly.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 25 Feb 2019 14:34:47 -0800
X-Gmail-Original-Message-ID: <CAHk-=whP-9yPAWuJDwA6+rQ-9owuYZgmrMA9AqO3EGJVefe8vg@mail.gmail.com>
Message-ID: <CAHk-=whP-9yPAWuJDwA6+rQ-9owuYZgmrMA9AqO3EGJVefe8vg@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: fix uninitialized return value in shmem_link
To: Hugh Dickins <hughd@google.com>, Jan Hubicka <hubicka@ucw.cz>, rguenth@gcc.gnu.org
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Matej Kupljen <matej.kupljen@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	Dan Carpenter <dan.carpenter@oracle.com>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: multipart/mixed; boundary="0000000000003feded0582bf8d04"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000003feded0582bf8d04
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 25, 2019 at 12:34 PM Hugh Dickins <hughd@google.com> wrote:
>
> Seems like a gcc bug? But I don't have a decent recent gcc to hand
> to submit a proper report, hope someone else can shed light on it.

I don't have a _very_ recent gcc either, but with gcc-8.2.1 the
attached test-case gives me:

   [torvalds@i7 ~]$ gcc -O2 -S -Wall test.c

with no warning, and then

   [torvalds@i7 ~]$ gcc -O2 -S -Wall -DHIDE_PROBLEM test.c
   test.c: In function =E2=80=98shmem_link=E2=80=99:
   test.c:60:9: warning: =E2=80=98ret=E2=80=99 may be used uninitialized in=
 this
function [-Wmaybe-uninitialized]
     return ret;
            ^~~

*does* show the expected warning.

So it is the presence of that

      if (ret) return ret;

that suppresses the warning.

What I *suspect* happens is

 (a) gcc sees that there is only one assignment to "ret"

 (b) in the same basic block as the assignment, there is a test
against "ret" being nonzero that goes out.

and what I think happens is that (a) causes gcc to consider that
assignment to be the defining assignment (which makes all kinds of
sense in an SSA world), and then (b) means that gcc decides that
clearly "ret" has to be zero in any case that doesn't go out due to
the if-test.

In fact, if I then look at the code generation, gcc will actually do
this (edited to be more legible):

        movl    (%rbx), %eax       <- load inode->i_nlink
        testl   %eax, %eax
        je      .L1
       ...
       ...
        call    d_instantiate
        xorl    %eax, %eax     <- explicitly zero 'ret'!
.L1:
        popq    %rbx
        popq    %rbp
        popq    %r12
        ret

so at least with my compiler, it *effectively* zeroed ret (in %rax)
anyway, and it all just _happened_ to get the right result even though
'ret' wasn't actually initialized.

Which is why it all worked just fine. And depending on how gcc works
internally, it really may not just be a random mistake of register
allocation, but really because gcc kind of _thought_ that 'ret' was
zero-initialized due to the combination of the one single assigment
and test for zero.

So it turns out that the patch to initialize to zero doesn't do
anything, probably for the same reason that gcc didn't warn about the
missing initialization. Gcc kind of added an initialization of its own
there.

I'm not entirely sure if any gcc developer would be interested in this
as a test-case, but I guess I can try to do a bugzilla.

Adding a few gcc people who have been on previous kernel gcc bugzilla
discussions, just in case they have something to add.

The gcc bugzilla is this:

    https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D89501

and I tried to make it be self-explanatory, but I wrote the bugzilla
in parallel with this email, and maybe there's some missing context
either there (or here).

                 Linus

--0000000000003feded0582bf8d04
Content-Type: text/x-c-code; charset="US-ASCII"; name="test.c"
Content-Disposition: attachment; filename="test.c"
Content-Transfer-Encoding: base64
Content-ID: <f_jskwlqay0>
X-Attachment-Id: f_jskwlqay0

LyoKICogTWluaW1hbCBmYWtlIGRlY2xhcmF0aW9ucyBvZiAia2VybmVsIiBkYXRhIHR5cGVzCiAq
LwpzdHJ1Y3Qgc3VwZXJibG9jazsKCnN0cnVjdCBpbm9kZSB7CglpbnQgaV9ubGluazsKCWludCBp
X3NpemU7CglpbnQgaV9jdGltZTsKCWludCBpX210aW1lOwoJc3RydWN0IHN1cGVyYmxvY2sgKmlf
c2I7Cn07CgpzdHJ1Y3QgZGVudHJ5IHsKCXN0cnVjdCBpbm9kZSAqZF9pbm9kZTsKfTsKCiNkZWZp
bmUgZF9pbm9kZShkZW50cnkpICgoZGVudHJ5KS0+ZF9pbm9kZSkKCmV4dGVybiBpbnQgY3VycmVu
dF90aW1lKHN0cnVjdCBpbm9kZSAqKTsKZXh0ZXJuIHZvaWQgaW5jX25saW5rKHN0cnVjdCBpbm9k
ZSAqKTsKZXh0ZXJuIHZvaWQgaWhvbGQoc3RydWN0IGlub2RlICopOwpleHRlcm4gdm9pZCBkZ2V0
KHN0cnVjdCBkZW50cnkgKik7CmV4dGVybiB2b2lkIGRfaW5zdGFudGlhdGUoc3RydWN0IGRlbnRy
eSAqLCBzdHJ1Y3QgaW5vZGUgKik7CmV4dGVybiBpbnQgc2htZW1fcmVzZXJ2ZV9pbm9kZShzdHJ1
Y3Qgc3VwZXJibG9jayAqKTsKCiNkZWZpbmUgQk9HT19ESVJFTlRfU0laRSAyMAoKLyoKICogVGhl
IGFjdHVhbCBmdW5jdGlvbiB3aGVyZSBJJ2QgaGF2ZSBleHBlY3RlZCBhIHdhcm5pbmcKICogYWJv
dXQgInJldCBtaWdodCBiZSB1c2VkIHVuaW5pdGlhbGl6ZWQiCiAqLwppbnQgc2htZW1fbGluayhz
dHJ1Y3QgZGVudHJ5ICpvbGRfZGVudHJ5LCBzdHJ1Y3QgaW5vZGUgKmRpciwKCQkgICAgICBzdHJ1
Y3QgZGVudHJ5ICpkZW50cnkpCnsKCXN0cnVjdCBpbm9kZSAqaW5vZGUgPSBkX2lub2RlKG9sZF9k
ZW50cnkpOwoJaW50IHJldDsKCgkvKgoJICogTm8gb3JkaW5hcnkgKGRpc2sgYmFzZWQpIGZpbGVz
eXN0ZW0gY291bnRzIGxpbmtzIGFzIGlub2RlczsKCSAqIGJ1dCBlYWNoIG5ldyBsaW5rIG5lZWRz
IGEgbmV3IGRlbnRyeSwgcGlubmluZyBsb3dtZW0sIGFuZAoJICogdG1wZnMgZGVudHJpZXMgY2Fu
bm90IGJlIHBydW5lZCB1bnRpbCB0aGV5IGFyZSB1bmxpbmtlZC4KCSAqIEJ1dCBpZiBhbiBPX1RN
UEZJTEUgZmlsZSBpcyBsaW5rZWQgaW50byB0aGUgdG1wZnMsIHRoZQoJICogZmlyc3QgbGluayBt
dXN0IHNraXAgdGhhdCwgdG8gZ2V0IHRoZSBhY2NvdW50aW5nIHJpZ2h0LgoJICovCglpZiAoaW5v
ZGUtPmlfbmxpbmspIHsKCQlyZXQgPSBzaG1lbV9yZXNlcnZlX2lub2RlKGlub2RlLT5pX3NiKTsK
I2lmbmRlZiBISURFX1BST0JMRU0KCQlpZiAocmV0KQoJCQlyZXR1cm4gcmV0OwojZW5kaWYKCX0K
CglkaXItPmlfc2l6ZSArPSBCT0dPX0RJUkVOVF9TSVpFOwoJaW5vZGUtPmlfY3RpbWUgPSBkaXIt
PmlfY3RpbWUgPSBkaXItPmlfbXRpbWUgPSBjdXJyZW50X3RpbWUoaW5vZGUpOwoJaW5jX25saW5r
KGlub2RlKTsKCWlob2xkKGlub2RlKTsJCS8qIE5ldyBkZW50cnkgcmVmZXJlbmNlICovCglkZ2V0
KGRlbnRyeSk7CQkvKiBFeHRyYSBwaW5uaW5nIGNvdW50IGZvciB0aGUgY3JlYXRlZCBkZW50cnkg
Ki8KCWRfaW5zdGFudGlhdGUoZGVudHJ5LCBpbm9kZSk7CglyZXR1cm4gcmV0Owp9Cg==
--0000000000003feded0582bf8d04--

