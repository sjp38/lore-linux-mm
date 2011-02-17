Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 849448D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:08:47 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1HH8CHb027499
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 09:08:13 -0800
Received: by iyi20 with SMTP id 20so2612254iyi.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 09:08:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1297960574.2769.20.camel@edumazet-laptop>
References: <20110216185234.GA11636@tiehlicka.suse.cz> <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
 <20110217090910.GA3781@tiehlicka.suse.cz> <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
 <1297960574.2769.20.camel@edumazet-laptop>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Feb 2011 09:07:47 -0800
Message-ID: <AANLkTikUF+gz8H3SkW4NhD8SOT5b4bxnpcJgsVU+G-bC@mail.gmail.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Content-Type: multipart/mixed; boundary=0014853d202e35b713049c7d71a3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Octavian Purdila <opurdila@ixiacom.com>, David Miller <davem@davemloft.net>

--0014853d202e35b713049c7d71a3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 17, 2011 at 8:36 AM, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> Le jeudi 17 f=E9vrier 2011 =E0 08:13 -0800, Linus Torvalds a =E9crit :
>>
>> Nope, that's roughly what I did to (in addition to doing all the .ko
>> files and checking for 0xe68 too). Which made me worry that the 0x1e68
>> offset is actually just the stack offset at some random code-path (it
>> would stay constant for a particular kernel if there is only one way
>> to reach that code, and it's always reached through some stable
>> non-irq entrypoint).
>>
>> People do use on-stack lists, and if you do it wrong I could imagine a
>> stale list entry still pointing to the stack later. And while
>> INIT_LIST_HEAD() is one pattern to get that "two consecutive words
>> pointing to themselves", so is doing a "list_del()" on the last list
>> entry that the head points to.
>>
>> So _if_ somebody has a list_head on the stack, and leaves a stale list
>> entry pointing to it, and then later on, when the stack has been
>> released that stale list entry is deleted with "list_del()", you'd see
>> the same memory corruption pattern. But I'm not aware of any new code
>> that would do anything like that.
>>
>> So I'm stumped, which is why I'm just hoping that extra debugging
>> options would catch it closer to the place where it actually occurs.
>> The "2kB allocation with a nice compile-time structure offset" sounded
>> like _such_ a great way to catch it, but it clearly doesn't :(
>>
>>
>
> Hmm, this rings a bell here.
>
> Unfortunately I have to run so cannot check right now.
>
> Please take a look at commit 443457242beb6716b43db4d (net: factorize
> sync-rcu call in unregister_netdevice_many)
>
> CC David and Octavian
>
> dev_close_many() can apparently return with an non empty list

Uhhuh. That does look scary. This would also explain why so few people
see it, and why it's often close to exit.

That __dev_close() looks very scary. When it does

  static int __dev_close(struct net_device *dev)
  {
         LIST_HEAD(single);

         list_add(&dev->unreg_list, &single);
         return __dev_close_many(&single);
  }

it leaves that "dev->unreg_list" entry on the on-stack "single" list.
"dev_close()" does the same.

So if "dev->unreg_list" is _ever_ touched afterwards (without being
re-initialized), you've got list corruption. And it does look like
default_device_exit_batch() does that by doing a
"unregister_netdevice_queue(dev, &dev_kill_list);" which in turn does
"list_move_tail(&dev->unreg_list, head);" which is basically just an
optimized list_del+list_add.

I haven't looked through the cases all that closely, so I might be
missing something that re-initializes the queue. But it does look
likely, and would explain why it's seen after a suspend (that takes
down the networking), and I presume Eric has been doing various
network device actions too, no?

Even if there is some guarantee that "dev->unreg_list" is never used
afterwards, I would _still_ strongly suggest that nobody ever leave
random pending on-stack list entries around when the function (that
owns the stack) exits. So at a minimum, you'd do something like the
attached.

TOTALLY UNTESTED PATCH! And I repeat: I don't know the code. I just
know "that looks damn scary".

[ Btw, that also shows another problem: "list_move()" doesn't trigger
the debugging checks when it does the __list_del(). So
CONFIG_DEBUG_LIST would never have caught the fact that the
"list_move()" was done on a list-entry that didn't have valid list
pointers any more. ]

                                  Linus

--0014853d202e35b713049c7d71a3
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gk9x6i3d0

IG5ldC9jb3JlL2Rldi5jIHwgICAgNyArKysrKy0tCiAxIGZpbGVzIGNoYW5nZWQsIDUgaW5zZXJ0
aW9ucygrKSwgMiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9uZXQvY29yZS9kZXYuYyBiL25l
dC9jb3JlL2Rldi5jCmluZGV4IDhlNzI2Y2IuLmExOGMxNjQgMTAwNjQ0Ci0tLSBhL25ldC9jb3Jl
L2Rldi5jCisrKyBiL25ldC9jb3JlL2Rldi5jCkBAIC0xMjgwLDEwICsxMjgwLDEzIEBAIHN0YXRp
YyBpbnQgX19kZXZfY2xvc2VfbWFueShzdHJ1Y3QgbGlzdF9oZWFkICpoZWFkKQogCiBzdGF0aWMg
aW50IF9fZGV2X2Nsb3NlKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpCiB7CisJaW50IHJldHZhbDsK
IAlMSVNUX0hFQUQoc2luZ2xlKTsKIAogCWxpc3RfYWRkKCZkZXYtPnVucmVnX2xpc3QsICZzaW5n
bGUpOwotCXJldHVybiBfX2Rldl9jbG9zZV9tYW55KCZzaW5nbGUpOworCXJldHZhbCA9IF9fZGV2
X2Nsb3NlX21hbnkoJnNpbmdsZSk7CisJbGlzdF9kZWwoJnNpbmdsZSk7CisJcmV0dXJuIHJldHZh
bDsKIH0KIAogaW50IGRldl9jbG9zZV9tYW55KHN0cnVjdCBsaXN0X2hlYWQgKmhlYWQpCkBAIC0x
MzI1LDcgKzEzMjgsNyBAQCBpbnQgZGV2X2Nsb3NlKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpCiAK
IAlsaXN0X2FkZCgmZGV2LT51bnJlZ19saXN0LCAmc2luZ2xlKTsKIAlkZXZfY2xvc2VfbWFueSgm
c2luZ2xlKTsKLQorCWxpc3RfZGVsKCZzaW5nbGUpOwogCXJldHVybiAwOwogfQogRVhQT1JUX1NZ
TUJPTChkZXZfY2xvc2UpOwo=
--0014853d202e35b713049c7d71a3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
