Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA10312
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 02:33:08 -0500
Subject: [PATCH] MM fix & improvement
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 09 Jan 1999 08:32:50 +0100
Message-ID: <87k8yw295p.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

This is a MIME multipart message.  If you are reading
this, you shouldn't.

--=-=-=

OK, here it goes. Patch is unbelievably small, and improvement is
BIG.

Two things:

1) Til' now, writing to swap files & partitions was clustered 
in 128kb chunks which is too small, especially now when we have swapin 
readahead (default 64kb). Fragmentation of swap file with such a value 
is big, so swapin readahead hit rate is probably small. Thus first
improvement is in increasing on-disk cluster size to much bigger
value. I chose 512, and it works very well, indeed (see below). All
this is completely safe.

2) There was an artificial limit in swapin readahead code, that is
completely unnecessary, and also kills performance a big time. It also 
makes trouble with two thrashing tasks, because swapin readahead
doesn't work very well in such low memory condition. I removed it
alltogether, and swapping quite improved.

If you don't believe, look at benchmarks I made for your eyes only
(swap cache statistics is after both runs):

pre6 + MM cleanup (needed for swap cache hit rate)
 
    hogmem 100 3	-	10.75 MB/sec
2 x hogmem 50 3		-	2.01 + 1.97 MB/sec (disk thrashing)
swap cache		-	add 194431 find 13315/194300 (6.9% hit rate)

pre6 + MM cleanup + patch below

    hogmem 100 3	-	13.27 MB/sec
2 x hogmem 50 3		-	6.15 + 5.77 MB/sec (perfect)
swap cache		-	add 175887 find 76003/237711 (32% hit rate)

Notice how swap cache done it's job much better with changes applied!!!

Both tests were run in single user mode, after reboot, on 64MB
machine. Don't be disappointed if you get smaller numbers, I have two
swap partitions on different disks and transports (IDE + SCSI). :)


--=-=-=
Content-Type: application/octet-stream
Content-Disposition: attachment
Content-Description: MM Improvement
Content-Transfer-Encoding: base64

SW5kZXg6IDIyMDYuMy9tbS9zd2FwZmlsZS5jCi0tLSAyMjA2LjMvbW0vc3dhcGZpbGUuYyBUdWUs
IDAxIERlYyAxOTk4IDExOjMyOjU4ICswMTAwIHpjYWx1c2ljIChsaW51eC0yLjEvei9iLzIwX3N3
YXBmaWxlLmMgMS4yIDY0NCkKKysrIDIyMDYuMyh3KS9tbS9zd2FwZmlsZS5jIFNhdCwgMDkgSmFu
IDE5OTkgMDg6MDg6NTIgKzAxMDAgemNhbHVzaWMgKGxpbnV4LTIuMS96L2IvMjBfc3dhcGZpbGUu
YyAxLjIgNjQ0KQpAQCAtMjMsNiArMjMsNyBAQAogCiBzdHJ1Y3Qgc3dhcF9pbmZvX3N0cnVjdCBz
d2FwX2luZm9bTUFYX1NXQVBGSUxFU107CiAKKyNkZWZpbmUgU1dBUEZJTEVfQ0xVU1RFUiAyNTYK
IAogc3RhdGljIGlubGluZSBpbnQgc2Nhbl9zd2FwX21hcChzdHJ1Y3Qgc3dhcF9pbmZvX3N0cnVj
dCAqc2kpCiB7CkBAIC0zMCw3ICszMSw3IEBACiAJLyogCiAJICogV2UgdHJ5IHRvIGNsdXN0ZXIg
c3dhcCBwYWdlcyBieSBhbGxvY2F0aW5nIHRoZW0KIAkgKiBzZXF1ZW50aWFsbHkgaW4gc3dhcC4g
IE9uY2Ugd2UndmUgYWxsb2NhdGVkCi0JICogU1dBUF9DTFVTVEVSX01BWCBwYWdlcyB0aGlzIHdh
eSwgaG93ZXZlciwgd2UgcmVzb3J0IHRvCisJICogU1dBUEZJTEVfQ0xVU1RFUiBwYWdlcyB0aGlz
IHdheSwgaG93ZXZlciwgd2UgcmVzb3J0IHRvCiAJICogZmlyc3QtZnJlZSBhbGxvY2F0aW9uLCBz
dGFydGluZyBhIG5ldyBjbHVzdGVyLiAgVGhpcwogCSAqIHByZXZlbnRzIHVzIGZyb20gc2NhdHRl
cmluZyBzd2FwIHBhZ2VzIGFsbCBvdmVyIHRoZSBlbnRpcmUKIAkgKiBzd2FwIHBhcnRpdGlvbiwg
c28gdGhhdCB3ZSByZWR1Y2Ugb3ZlcmFsbCBkaXNrIHNlZWsgdGltZXMKQEAgLTQ2LDcgKzQ3LDcg
QEAKIAkJCWdvdG8gZ290X3BhZ2U7CiAJCX0KIAl9Ci0Jc2ktPmNsdXN0ZXJfbnIgPSBTV0FQX0NM
VVNURVJfTUFYOworCXNpLT5jbHVzdGVyX25yID0gU1dBUEZJTEVfQ0xVU1RFUjsKIAlmb3IgKG9m
ZnNldCA9IHNpLT5sb3dlc3RfYml0OyBvZmZzZXQgPD0gc2ktPmhpZ2hlc3RfYml0IDsgb2Zmc2V0
KyspIHsKIAkJaWYgKHNpLT5zd2FwX21hcFtvZmZzZXRdKQogCQkJY29udGludWU7CkluZGV4OiAy
MjA2LjMvbW0vcGFnZV9hbGxvYy5jCi0tLSAyMjA2LjMvbW0vcGFnZV9hbGxvYy5jIFNhdCwgMDkg
SmFuIDE5OTkgMDQ6MDc6MDMgKzAxMDAgemNhbHVzaWMgKGxpbnV4LTIuMS96L2IvMjZfcGFnZV9h
bGxvYyAxLjIuNi4xLjEuMi40LjEuMS4yIDY0NCkKKysrIDIyMDYuMyh3KS9tbS9wYWdlX2FsbG9j
LmMgU2F0LCAwOSBKYW4gMTk5OSAwODowODo1MiArMDEwMCB6Y2FsdXNpYyAobGludXgtMi4xL3ov
Yi8yNl9wYWdlX2FsbG9jIDEuMi42LjEuMS4yLjQuMS4xLjIgNjQ0KQpAQCAtMzcwLDkgKzM3MCw3
IEBACiAJb2Zmc2V0ID0gKG9mZnNldCA+PiBwYWdlX2NsdXN0ZXIpIDw8IHBhZ2VfY2x1c3RlcjsK
IAkKIAlmb3IgKGkgPSAxIDw8IHBhZ2VfY2x1c3RlcjsgaSA+IDA7IGktLSkgewotCSAgICAgIGlm
IChvZmZzZXQgPj0gc3dhcGRldi0+bWF4Ci0JCQkgICAgICB8fCBucl9mcmVlX3BhZ2VzIC0gYXRv
bWljX3JlYWQoJm5yX2FzeW5jX3BhZ2VzKSA8Ci0JCQkgICAgICAoZnJlZXBhZ2VzLmhpZ2ggKyBm
cmVlcGFnZXMubG93KS8yKQorCSAgICAgIGlmIChvZmZzZXQgPj0gc3dhcGRldi0+bWF4KQogCQkg
ICAgICByZXR1cm47CiAJICAgICAgaWYgKCFzd2FwZGV2LT5zd2FwX21hcFtvZmZzZXRdIHx8CiAJ
CSAgc3dhcGRldi0+c3dhcF9tYXBbb2Zmc2V0XSA9PSBTV0FQX01BUF9CQUQgfHwK

--=-=-=


-- 
Zlatko

--=-=-=--
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
