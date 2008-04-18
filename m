Date: Fri, 18 Apr 2008 19:07:49 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <ab3f9b940804171223m722912bfy291a2c6d9d40b24a@mail.gmail.com>
References: <20080417182121.A8CA.KOSAKI.MOTOHIRO@jp.fujitsu.com> <ab3f9b940804171223m722912bfy291a2c6d9d40b24a@mail.gmail.com>
Message-Id: <20080418170129.A8DF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="------_4808555800000000A969_MULTIPART_MIXED_"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tom May <tom@tommay.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--------_4808555800000000A969_MULTIPART_MIXED_
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

> madvise can be replaced with munmap and the same behavior occurs.
> 
> --- test.c.orig 2008-04-17 11:41:47.000000000 -0700
> +++ test.c 2008-04-17 11:44:04.000000000 -0700
> @@ -127,7 +127,7 @@
>     /* Release FREE_CHUNK pages. */
> 
>     for (i = 0; i < FREE_CHUNK; i++) {
> -       int r = madvise(p + page*PAGESIZE, PAGESIZE, MADV_DONTNEED);
> +       int r = munmap(p + page*PAGESIZE, PAGESIZE);
>         if (r == -1) {
>             perror("madvise");
>             exit(1);
> 
> Here's what I'm seeing on my system.  This is with munmap, but I see
> the same thing with madvise.  First, /proc/meminfo on my system before
> running the test:

Oh sorry my bad!
I investigated again and found 2 problem in your test program.

1. text segment isn't locked.

   if strong memory pressure happned, kernel may drop program text region.
   then your test program suddenly slow down.

   please use mlockall(MCL_CURRENT) before large buffer allocation.

2. repeat open/close to /proc/meminfo.
   
   in the fact, open(2) system call use a bit memory.
   if call open(2) in strong memory pressure, doesn't return until
   memory freed enough.
   thus, it cause slow down your program sometimes.

attached changed test program :)
it works well on my test environment.


> If it's possible to get a notification when MemFree + Cached + Mapped
> (I'm not sure whether this is the right formula) falls below some
> threshold, so that the program has time to find memory to discard
> before the system runs out, that would prevent the oom -- as long as
> the application(s) can ensure that there is not too much memory
> allocated while it is looking for memory to free.   But at least the
> threshold would give it a reasonable amount of time to handle the
> notification.

your proposal is interesting.
but I hope try to my attached test program at first.

--------_4808555800000000A969_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="tom.c"
Content-Disposition: attachment;
 filename="tom.c"
Content-Transfer-Encoding: base64

I2RlZmluZSBfR05VX1NPVVJDRQ0KI2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3RkbGli
Lmg+DQojaW5jbHVkZSA8c3lzL21tYW4uaD4NCiNpbmNsdWRlIDxzeXMvdHlwZXMuaD4NCiNpbmNs
dWRlIDxzeXMvc3RhdC5oPg0KI2luY2x1ZGUgPGZjbnRsLmg+DQojaW5jbHVkZSA8cG9sbC5oPg0K
I2luY2x1ZGUgPHNjaGVkLmg+DQojaW5jbHVkZSA8dGltZS5oPg0KI2luY2x1ZGUgPHVuaXN0ZC5o
Pg0KI2luY2x1ZGUgPHB0aHJlYWQuaD4NCg0KI2RlZmluZSBQQUdFU0laRSAoNjQqMTAyNCkNCg0K
LyogSG93IG1hbnkgcGFnZXMgd2UndmUgbW1hcCdkLiAqLw0Kc3RhdGljIGxvbmcgcGFnZXM7DQoN
Ci8qIFBvaW50ZXIgdG8gbW1hcCdkIG1lbW9yeSB1c2VkIGFzIGEgY2lyY3VsYXIgYnVmZmVyLiAg
T25lIHRocmVhZA0KICAgdG91Y2hlcyBwYWdlcywgYW5vdGhlciB0aHJlYWQgcmVsZWFzZXMgdGhl
bSBvbiBub3RpZmljYXRpb24uICovDQpzdGF0aWMgY2hhciAqcDsNCg0KLyogSG93IG1hbnkgcGFn
ZXMgdG8gdG91Y2ggZWFjaCA1bXMuICBUaGlzIG1ha2VzIGF0IG1vc3QgMjAwMA0KICAgcGFnZXMv
c2VjLiAqLw0KI2RlZmluZSBUT1VDSF9DSFVOSyAxMA0KDQovKiBIb3cgbWFueSBwYWdlcyB0byBm
cmVlIHdoZW4gd2UncmUgbm90aWZpZWQuICBXaXRoIGEgMTAwbXMgRlJFRV9ERUxBWSwNCiAgIHdl
IGNhbiBmcmVlIH45MTEwIHBhZ2VzL3NlYywgb3IgcGVyaGFwcyBvbmx5IDUqOTExID0gNDU1NSBw
YWdlcy9zZWMgaWYgd2UncmUNCiAgIG5vdGlmaWVkIG9ubHkgNSB0aW1lcy9zZWMuICovDQojZGVm
aW5lIEZSRUVfQ0hVTksgOTExDQoNCi8qIERlbGF5IGluIG1pbGxpc2Vjb25kcyBiZWZvcmUgZnJl
ZWluZyBwYWdlcywgdG8gc2ltdWxhdGUgbGF0ZW5jeSB3aGlsZSBmaW5kaW5nDQogICBwYWdlcyB0
byBmcmVlLiAqLw0KI2RlZmluZSBGUkVFX0RFTEFZIDEwMA0KDQpzdGF0aWMgdm9pZCB0b3VjaCh2
b2lkKTsNCnN0YXRpYyBpbnQgcmVsZWFzZSh2b2lkICphcmcpOw0Kc3RhdGljIHZvaWQgcmVsZWFz
ZV9wYWdlcyh2b2lkKTsNCnN0YXRpYyB2b2lkIHNob3dfbWVtaW5mbyh2b2lkKTsNCnN0YXRpYyB2
b2lkKiBfcmVsZWFzZSAodm9pZCAqYXJnKTsNCg0KaW50DQptYWluIChpbnQgYXJnYywgY2hhciAq
KmFyZ3YpDQp7DQoJcHRocmVhZF90IHRocjsNCg0KCW1sb2NrYWxsKE1DTF9DVVJSRU5UKTsgLyog
bG9jayB0ZXh0Ki8NCglzZXR2YnVmKHN0ZG91dCwgKGNoYXIgKilOVUxMLCBfSU9MQkYsIDApOw0K
DQoJcGFnZXMgPSBhdG9sKGFyZ3ZbMV0pICogMTAyNCAqIDEwMjQgLyBQQUdFU0laRTsNCg0KCXAg
PSBtbWFwKE5VTEwsIHBhZ2VzICogUEFHRVNJWkUsIFBST1RfUkVBRCB8IFBST1RfV1JJVEUsDQoJ
CSBNQVBfUFJJVkFURSB8IE1BUF9BTk9OWU1PVVMgfCBNQVBfTk9SRVNFUlZFLCAwLCAwKTsNCglp
ZiAocCA9PSBNQVBfRkFJTEVEKSB7DQoJCXBlcnJvcigibW1hcCIpOw0KCQlleGl0KDEpOw0KCX0N
Cg0KCWlmKHB0aHJlYWRfY3JlYXRlKCZ0aHIsIE5VTEwsIF9yZWxlYXNlLCBOVUxMKSkgew0KCQlw
ZXJyb3IoInB0aHJlYWRfY3JlYXRlIik7DQoJCWV4aXQoMSk7DQoJfQ0KDQoNCgl0b3VjaCgpOw0K
CXJldHVybiAwOw0KfQ0KDQpzdGF0aWMgdm9pZA0KdG91Y2ggKHZvaWQpDQp7DQoJbG9uZyBwYWdl
ID0gMDsNCg0KCXdoaWxlICgxKSB7DQoJCWludCBpOw0KCQlzdHJ1Y3QgdGltZXNwZWMgdDsNCgkJ
Zm9yIChpID0gMDsgaSA8IFRPVUNIX0NIVU5LOyBpKyspIHsNCgkJCXBbcGFnZSAqIFBBR0VTSVpF
XSA9IDE7DQoJCQlpZiAoKytwYWdlID49IHBhZ2VzKSB7DQoJCQkJcGFnZSA9IDA7DQoJCQl9DQoJ
CX0NCg0KI2lmIDENCgkJdC50dl9zZWMgPSAwOw0KCQl0LnR2X25zZWMgPSA1ICogMTAwMCAqIDEw
MDA7IC8qIDVtcyAqLw0KCQlpZiAobmFub3NsZWVwKCZ0LCBOVUxMKSA9PSAtMSkgew0KCQkJcGVy
cm9yKCJuYW5vc2xlZXAiKTsNCgkJfQ0KI2VuZGlmDQoJfQ0KfQ0KDQpzdGF0aWMgaW50DQpyZWxl
YXNlICh2b2lkICphcmcpDQp7DQoJaW50IGZkID0gb3BlbigiL2Rldi9tZW1fbm90aWZ5IiwgT19S
RE9OTFkpOw0KCWlmIChmZCA9PSAtMSkgew0KCQlwZXJyb3IoIm9wZW4oL2Rldi9tZW1fbm90aWZ5
KSIpOw0KCQlleGl0KDEpOw0KCX0NCg0KCXdoaWxlICgxKSB7DQoJCXN0cnVjdCBwb2xsZmQgcGZk
Ow0KCQlpbnQgbmZkczsNCg0KCQlwZmQuZmQgPSBmZDsNCgkJcGZkLmV2ZW50cyA9IFBPTExJTjsN
Cg0KCQlwcmludGYoInBvbGxcbiIpOw0KCQluZmRzID0gcG9sbCgmcGZkLCAxLCAtMSk7DQoJCWlm
IChuZmRzID09IC0xKSB7DQoJCQlwZXJyb3IoInBvbGwiKTsNCgkJCWV4aXQoMSk7DQoJCX0NCgkJ
cHJpbnRmKCJub3RpZnlcbiIpOw0KCQlpZiAobmZkcyA9PSAxKSB7DQoJCQlzdHJ1Y3QgdGltZXNw
ZWMgdDsNCgkJCXQudHZfc2VjID0gMDsNCgkJCXQudHZfbnNlYyA9IEZSRUVfREVMQVkgKiAxMDAw
ICogMTAwMDsNCgkJCWlmIChuYW5vc2xlZXAoJnQsIE5VTEwpID09IC0xKSB7DQoJCQkJcGVycm9y
KCJuYW5vc2xlZXAiKTsNCgkJCX0NCgkJCXByaW50Zigid2FrZXVwXG4iKTsNCgkJCXJlbGVhc2Vf
cGFnZXMoKTsNCgkJCXByaW50ZigidGltZTogJWxkXG4iLCB0aW1lKE5VTEwpKTsNCi8vCQkJc2hv
d19tZW1pbmZvKCk7DQoJCX0NCgl9DQp9DQoNCnN0YXRpYyB2b2lkKg0KX3JlbGVhc2UgKHZvaWQg
KmFyZykNCnsNCglyZWxlYXNlKGFyZyk7DQoJcmV0dXJuIE5VTEw7DQp9DQoNCnN0YXRpYyB2b2lk
DQpyZWxlYXNlX3BhZ2VzICh2b2lkKQ0Kew0KCS8qIEluZGV4IG9mIHRoZSBuZXh0IHBhZ2UgdG8g
ZnJlZS4gKi8NCglzdGF0aWMgbG9uZyBwYWdlID0gMDsNCglpbnQgaTsNCg0KCS8qIFJlbGVhc2Ug
RlJFRV9DSFVOSyBwYWdlcy4gKi8NCg0KCWZvciAoaSA9IDA7IGkgPCBGUkVFX0NIVU5LOyBpKysp
IHsNCgkJaW50IHIgPSBtYWR2aXNlKHAgKyBwYWdlKlBBR0VTSVpFLCBQQUdFU0laRSwgTUFEVl9E
T05UTkVFRCk7DQoJCWlmIChyID09IC0xKSB7DQoJCQlwZXJyb3IoIm1hZHZpc2UiKTsNCgkJCWV4
aXQoMSk7DQoJCX0NCi8vCQlwcmludGYoImZyZWUgJXBcbiIsIHAgKyBwYWdlKlBBR0VTSVpFKTsN
CgkJaWYgKCsrcGFnZSA+PSBwYWdlcykgew0KCQkJcGFnZSA9IDA7DQoJCX0NCgl9DQp9DQoNCnN0
YXRpYyB2b2lkDQpzaG93X21lbWluZm8gKHZvaWQpDQp7DQoJY2hhciBidWZmZXJbMjAwMF07DQoJ
aW50IGZkOw0KCXNzaXplX3QgbjsNCg0KCWZkID0gb3BlbigiL3Byb2MvbWVtaW5mbyIsIE9fUkRP
TkxZKTsNCglpZiAoZmQgPT0gLTEpIHsNCgkJcGVycm9yKCJvcGVuKC9wcm9jL21lbWluZm8pIik7
DQoJCWV4aXQoMSk7DQoJfQ0KDQoJbiA9IHJlYWQoZmQsIGJ1ZmZlciwgc2l6ZW9mKGJ1ZmZlcikp
Ow0KCWlmIChuID09IC0xKSB7DQoJCXBlcnJvcigicmVhZCgvcHJvYy9tZW1pbmZvKSIpOw0KCQll
eGl0KDEpOw0KCX0NCg0KCW4gPSB3cml0ZSgxLCBidWZmZXIsIG4pOw0KCWlmIChuID09IC0xKSB7
DQoJCXBlcnJvcigid3JpdGUoc3Rkb3V0KSIpOw0KCQlleGl0KDEpOw0KCX0NCg0KCWlmIChjbG9z
ZShmZCkgPT0gLTEpIHsNCgkJcGVycm9yKCJjbG9zZSgvcHJvYy9tZW1pbmZvKSIpOw0KCQlleGl0
KDEpOw0KCX0NCn0NCg==
--------_4808555800000000A969_MULTIPART_MIXED_--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
