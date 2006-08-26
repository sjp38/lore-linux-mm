From: Blaisorblade <blaisorblade@yahoo.it>
Date: Sat, 26 Aug 2006 19:33:35 +0200
MIME-Version: 1.0
Subject: [PATCH RFP-V4 00/13] remap_file_pages protection support - 4th attempt
Content-Disposition: inline
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_wXI8E8FVAQxxYzi"
Message-Id: <200608261933.36574.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Jeff Dike <jdike@addtoit.com>, user-mode-linux-devel@lists.sourceforge.net, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Val Henson <val.henson@intel.com>
List-ID: <linux-mm.kvack.org>

--Boundary-00=_wXI8E8FVAQxxYzi
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Again, about 4 month since last time (for lack of time) I'm sending for final 
review and for inclusion into -mm protection support for remap_file_pages (in 
short "RFP prot support"), i.e. setting per-pte protections (beyond file 
offset) through this syscall.

Since last release, I've changed the PTE bits encoding I've used to avoid 
adding overhead in pte_present() - I don't remember complaints other than this 
one. UML support should follow in a short time.

Below there is the commentary I included last time, with some updates.
I've also attached the program I use for unit testing of the patch.

The patches themselves will only go to akpm, LKML and linux-mm, to avoid an 
invasion of your mailboxes :-)

After this batch of patches has been merged, I will be able to start further 
work basing on those - optimizations, restructuring and such, but the 
functionality is already present; since I had little time I decided to work 
on the basic set first, to avoid too many ports to newer releases.

== Notes ==

Arch-specific bits are provided for i386, x86_64 and UML, and for some other 
archs I have patches I will send, based on the ones which were in -mm when 
Ingo sent the first version of this work.

You shouldn't worry for the number of patches, most of them are very little.
I've last tested them in UML, i386 x86-64 against 2.6.18-rc3/rc4 (where 
_tested_ means compile, boot and unit-tested).

== How it works ==

Protections are set in the page tables when the page is loaded, are saved into 
the PTE when the page is swapped out and restored when the page is faulted 
back in.

Additionally, we modify the fault handler since the VMA protections aren't 
valid for PTE with modified protections.

Finally, we must also provide, for each arch, macros to store also the 
protections into the PTE; to make the kernel compile for any arch, I've added 
since last time dummy default macros to keep the same functionality.

== What is this for ==

The first idea is to use this for UML - it must create a lot of single page 
mappings, and managing them through separate VMAs is slow (in last discussion 
Ingo Molnar provided impressive numbers about this).

With a little additional change (to allow limited usage on MAP_PRIVATE 
readonly VMAs) it will be possible to use this also for shared objects guard 
pages on x86_64; guard pages for thread stacks can also be easily addressed; 
handling read/write private vmas (which was in Ulrich's wish list) was also 
maybe possible but there are limitations for that so I've left that totally 
apart.
-- 
Inform me of my mistakes, so I can keep imitating Homer Simpson's "Doh!".
Paolo Giarrusso, aka Blaisorblade
http://www.user-mode-linux.org/~blaisorblade

--Boundary-00=_wXI8E8FVAQxxYzi
Content-Type: application/x-bzip2;
  name="fremap-test-complete.c.bz2"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="fremap-test-complete.c.bz2"

QlpoOTFBWSZTWWrwT10ACJNfgFwwe///f7////6////+YBncC+5zd0AO2qp0Gh9z22vDx2DWed49
7xVzCizaod93eSwCQ3xuuvna7bLdzcpKVbGnbuzZKl3j3vVHowlCCNATCDQJJ+kzQnqKb1PI0jRH
kaammmRo9CabJA1PRMQTRBomphI9TE9JoBkAAANBoAABET0UAAAaNAAAAaAAAA0AAAk0lEmEEwp6
aNU/VPUzFH6o2oZ6kekNAzUB6h6gAACJRMSaJiNBomRMU9I/VG1DTGozRPSG1NG0j1A0yNAJERNB
Mk9AiYmqfqeqe0nqeknknlA9I9Q9INDEaBoBp72sD5toWQm2QgiKIkVRjCLBREixQUkRUixSCgjF
grBSIMWCAIgLAWLBSLIoJIgKKJEUiMFjEFFixiIwYKRQYLBWKwYCqIkYqxYKCrIKCkRFiRhEQFiC
GCfEuvcWJ9w30c4NMyx5Mh9zDycjq/Xp3QCErP/S97Y0okViAjtirJNPdJIDHPNucpUTG1rpKm6E
MqGAQPz12EqMOUQipJp3K7pt40/fGD+fFmX71jAutgc9UGhV5rLIiD8FEYzdAsIvPxrOViwIpCGd
Cobcp8qGxPYlQHZd92pieP25IbHak8vHx5ypuZyQYQ4JuEPpOJitbGU5eztwVKFYJUYtwbK0bbKu
C/1dnrfpfbx6uGW/fpw3ulU604N8ueGuTCq5ZO9Dkes3YxqcfNmlary38E8En7NurLYJOHub+YTA
HUQC1ytWKh+/s2RrpGu6TJVRTtT8p6Pgz0WMoW+tfri3uVHKnQsUJLrW3r/KvdmwjNpjlH8pzViw
Kpl8efLlXarlRVMKmBzniDMKibAyvYD5UmvupP2pOPmeek0qLylp14r5uvl2zeqR2vSiZ9zypyDI
eKpx+4d2cKAWZGipmRX+tEckCVNT/f+fn3G87++ua8NscQdiqucKGBk5zbq6fWyqzDP6OMZwMUMN
I33++MUDCIwnP6eXKx4cVMFat5ijnLS6CovIf1dBwWeLZ2aeCyb4GwHTwq6LuaDtS+2nhRNpEpnj
pO3RY6dRnS6c1J9qsCKInkXhKeS9LzzsVK9/TXRQfbULB3fP5kwf5VHZOkQIT5u7NVhm4ZxccMk/
VTIRL0ReO4icH+W9X75ScyFD3rLO+lR8KJ/jCK74wVKGGryYJvmCquYPFEaxS7993RfqXebxRm7e
rHKWPRaIoohspVV9+1RS0qf+kfeVNDkJZSNVsjzRm87p8enHL2ef08nGYvsy9dlBliFDvSayaLyD
YuQHYsMKoegYYOzB7nj6352flE9M83KA3Lfrt2DdjEupeGM8q1NETZPkagbwmUpZUpGauJaGZkfT
VD4WudbbS6ama54xHdfzd79Pq7PA8ueK8PgtVnkRYYa00G1WsddelaipDB0uDzPJVCKWN+EOw89c
q1TmsDdB1ZROosTarZfeIWpjVdThONS31AZmvHwfg/bCMSYBTbeXCe1wOqXLbA0gbIKaOzZBkwAh
J4Mu4pMCeKLeeR2rDAJ64W4/HDr21XTPCT/YqZJ5Gtij94S4qn5yQmjQ6J85etc7t/66Gt/EmHPs
s4oZ48ualUUgJI9rqiQ62eL058bN848VexuDyQysOKdWiqd13sAna2DnfJGg1Nppe1NEGaPFrurG
bGW23+ncR8hGKpmDcIRocTaZxPiAi85Z3zSdahnbzVVapD7rRYPYVE9wlqoFyLO6Ft+3I77fxaZp
GjzvyR5uucCFtCLKR67ducgCw1vnfbwxc0ztjojVM2iy3WzJBUnrthdhlB1Wd3JpOaebWT119amE
wSOZTO5phqUW8oZ772MnQYPoAiIsl4HBFibQ3DaHU9+LltlFRM6NSK+BVynTruHsTVUeXWvNPh3r
Vyapp2ropk81aaDG+b0MagUnMp08G78q1yyqDIRre8pyAKZAP1aP0RvVJUyKkjUjmC5vdsp7205+
zSbLYBK07LtCTQDQg1aeQcAvW8h1uzMg9MQoxGQPIfG4y9ninvqRiddtl3b1pc14fN78Ury8qYee
F7bWk3gbBHWtYD1M+p1b5U+WhDDBlO7ppQrv+Yk1mAKtSyJINJW08hBhFgR9zZtyhjHEqMooygJL
U9ij88QUkErJEDI9wqUkj0xTqin3v9QgC9iqz1AxjbSLGyIvh/Izr7zq3JcJLVBD6wTtYAMQ0EDA
0jrNr9Qah40b8FGNMZUqrgCBDT+E90CPNm/bOTM84w4DWh4MPEUWd4dqljZpVmucCVEnRT3MJUEC
FlQw8giW6OlHUoo4FCVmMrYxOru8NWz7Nhy6D6Xd6+lm9yuVGU8l6U52zuaAvA+k27dAD782f7GZ
fbVp0KM+ws8UYYy7ln0EEhRC6PbnzVsaKNGN0HlMp4r41hKYhhwgooKKt/AQDpTvQZyHho+1NJMO
XmVV+WFW81VkCZpU3ofm40GnOvGdNSg1JNjnGmcXGtU0ZsuHl8tNdkb9TfZokgzkICDIZWV9NzdL
W+tlBOA+tM7vujo7ay9GXdUgIQCCUVi2mJMYdIzq+RumwLA+8m12JpNeg2454XdzIgcEPFMFVaEF
ICNeQCNvPcPZnf866XE/PuNIZJ17zjCoahHrFReZWdqm9GwmKZxlu6HFuYs6ilBpwIuBU5ojoFtM
73C54F/jhsqXU6KxNnkzWpEl0v0WwQ9WV1evXrp7Kf7aDbd20VSxqx0TlqJTeoqqk2ZTjF5Y+lf9
bVeOqXf/Rh86GvWxa+eKMUc18f5SJh3xOg4qJQbdAEKo7vy1UDw9Ekg9w8l4t1deduGtK+Lh2UlG
O+VPmJksHeE3WFK7ozfJZ5koWFvM5N5x+s2lJZT5+x2D+Drcuk4xdk2umvq8T8UJ+xPT8Zw1/EIC
AsFBWIKjGJEFkFZkCHN5r2IciLD9vdMx0t+Olfe2B2Q3RJMfMUfNGkB87TB3MsE/IFxfbFDzyEMZ
tGKbalK8srB9MyPLiuJTTzr6Pi23cj00FCIAZCYJp5FpIX9gc2+plnA+Ic2CtetIPAcrWE+u64uj
4HhxJ5RmHf3+rymcJjfo9hdxpcfBJYXht65APS82gJ6Y584Re0eDbVmoaCWHk91rUswl5MES1+9g
qMMmMaMnvZLF2NGDNOH4ctuOdqNIqQVysqEKpQjHnmGWdW8IoZMmLmaUdIAe09jBbST6Lhl6bT3W
6FKgKCkk7T1klO/hTtm/5T0qeIEofYQoIf6VD3FyPYqZ+tcLUCDDA/ceP7XUftkhDYX1isez0c+3
7F+BTe4P72xU/KXplWAfDkfyU/gp9NhbxkBkTumqJEhQWMMjKzj/TOBhHdvSoopBImoz6rtRsAbS
wwiOHRlE39JIf8WFKYrJJS0RlgsCiVARWPFIHYkDQjYw/ccyNKj6BhYWV/beHSFBF9vKrSupZrSq
lYSH+gBpLeLEJAw5kZGtguNigjCAhbFQMmmpYEWEWWKFnhX9OgroHF5hUKrKhtXte3e6HUAZgRUu
UyKrVcCRJATiREcjHIY0e5TKz0cB4jdc0NoqHIaD4QC48OVm5t1HYbFahBdaCcNzA97mDWRefd2v
abktqOJQWgpOpIYksM89tG222GpYqk6Y20Gzd+Cxud6mGmACqwesaCoUDJdFu/bPXKi7IgXwPWqc
blgyW9SBupOHOpd7G5BDgKh3DRex6k8BqU4tTqQLxAYDEGIsMAD7OQG0jNHla5scGmIfL7pfZUUD
zxOqcU6+s7iZDU0koWbEJuTgmRkGDOSo2iG6HFJCztlJ1gWaG4J1DIRWMOFzdV624cHodToKaBZa
hQEYGFytIbw6zia7TK8OA1mw5YhRyhsIbGOCjAK32ssaoUYcTfNp272OT0Y4ykJoZKhsRfWVEiIA
mv8qCnYnqRj2vWDIygpfLl04UgWuW1yhDolGlFpKW5ahuVgli2Y5AYY9wjRM2GoCi1CwHFqlEYCw
sHJu3Gu3dq7j73ali4rAz5mi7g5HY2OVDlCzZ6jdcxKhXFrqm8S/RBamIBSAlNdwDM1QCN1ZgBJM
nn4wtJTsiIHrCDvnOT0e/f1u9nlcNFWRAhSyohp/VQVhFDCcwbAEFxCCGMCoNiM9ANAO5Hhi0iBw
fUp1LuVA7IOISesJlGR3ncrhlERA4TgXOlmBU74SHm1A5skmaHvyEQomwPMGGrd9GCRdkyaCJvNd
2o1FpbQCzhqejLtsrIUQRFUWG2QeAtIcQG6nAEg2MhCgQaPs9XNxB+EIZ/gA+tDKIeMk7DyvkBI+
b1jcDUV/d8oGtE70PpAuuY5OPr1A9wevm9z0CTjpYnelT0pwT/OkhsZ+f5KZxWTWEr67buAL5/Z8
izRztFi0Kq4H116UIWx2CPdYCbYkfzk9fkA2zL3jICiBvUDPe7F0f3dwnvDbgBO/nviTk0spBZT8
W2DxLxCPGwGd1BtBKXQ8y/1ul28zQotVRW/zHtKipcFsEvvpgLq43dD35VlML6jqcw3yPN1CRRGa
0MRa6v9Bv+BB326eRC0eBt6+jvmsTy/FiVlhzCa0YSyNLfwVMXkzRvGBXvR3rCMgvKYZzIp34EHx
TVc9YAwPM+ZqIxQT+1wsbbFnS2aS6NcAsPyA8+LLJEh3LObIq8GEixHjZ4OqgzTlr/KnKwYyGumr
h3M2b0C6mhrmxIVCsysTTLoWg44uM7YJo2XIrRAyjGibyZJlKrJmkIOsrHErdKUAW2+RnA8d00Qx
psaIp1G7YbxLaTLuXEKZmwWhl9gkMaBgMCzRCpwwnnoBDBJ5G7hRKGHEqYsKKt2zU1uojrDO+EHa
34BSE2ePz2/9tFxib1HTK9RdIUkiFC9e6d/u0zhqQZWWajwQiwYJIC1tJc69wqbQtmVQlBSMsIry
sDLFElPFlogDKMaBmyDmjnIi5eaJXppOiyxN2ElpJ0jDyrEQEUghVUILUIKIBWsxMgyhoosrRlF9
1MpCwYAjBqCGvSmNmI/Bll0HwB9cwOoOE8Rw3blZIVJhTIhvEEYK6VWrQmigCGGyZdIjppE1dbnE
sqlMKaQri1Dfc0whowBaXyIxUKYxzwye5tDwQTsAjHY+GW9MEoEqcMy7XSBshaoOMHag0BKEmBVU
VIW60fiLhUc1GJK0nImZH/RAJ65GxNCJ184qpdSz/2xhOC2TGoTMulzGj+GAF2Ni+i5/jNUxGoWO
2HYbeKyqepr+C0YxF0AZKlRFm3m66lyqildSdlAJ4CXXskOQ1LBgXDiINkkIah7e8knQhA63zMFC
KrjRpyjD6EyhDCi0bvblir36ayIGVaPCL27+VhWQiPAxMspuUiNVcslsEKMBMkBJpT6KTisLTgRI
bUmpDDOg12Mk4DJWSi1iSwBe9VkWkUM03TYMM8YCuAhqSUtkKUPAW2h8+vEYYIqHLzHPB7YkgQhI
72GYzAOTLzGB4kMcI0B0BN1kmCEGET4m/GFX5WUklpsVfRkKVmuV4t0Id0pHqCYArUTnac9RfzOV
vd1NqQ+RUTWqGu+eqIIk3G0EtVEhAKCNSrRymPDFM2HlgJU28lN0VeRCAU4h1srPRMjkG/RRaOjr
5Bcjq/CtH2k+76napC4D6+jfhn4kxGvOyjpDeE0t01Cr811vJQqSG2JGHOzyp67lsRMpg5QwHhtk
JNnH5+EhvEF7jom/mVgqxFJz6Q1OzIc5s3POw+WAN3RogxiOoF5U1gWNvdzW59Q7KCy4/Sc6kDpY
b976eW7tL88roTv6jbNmzx6eXfQKCi2lFYihaEt8hmMDs8OkPm9vq83M0CnYk8iO3JgAasCiNN2y
snnrNKKCQql6bJbWv4uG20ZhkBqZ4pcTZ8bEjpw1EiolAuCfHmxezZSefea3nInkC++vkvwc/TN4
OuoW1hwMwIKiKdL0EhHxxxI5aS0ud1qxtiaw4XXUzBtywzHlpGY1UHmJSJ79DEk/VkWPzahBb120
kjCP0MO2urmrerQ0NCOMppbpaNLR0yrNhOZJAjs54cQVLOLSXC4FGFQOkn6fRkrwpdhdQQoqCpoa
0jYFwPppqBoEmkhYQmqKZqgRWG/q3Nuky16GpsJILEiQIJpApuL6lJaUAbqkDuuMe+MZaDpaKsuM
zHBJNJQwVRpEFEQwaQl2yi64pNxptw3SoiY4FEeDFLUMOTQ/obKY8dcUidNqyIQtFnB5fSY4u4PV
AOLw9Ga/OdR4chz68wioxiMVV3/ncKlKjH85mLcD1rFi5BVeRVVi7gl6iIVGEuByHPE3qO6EukMw
hEW4FRLYeMlkiopjDU/gGHo3IHYWIqWoRDG5H0mhFuEtr3mZS9WyNIos/LIw2p4YtTEoQ3w8/eX4
XuZPBKIfD52kjACL7uxV8IG2QqUAyLhxoeDfYHjicGXVfhhqhLwgDawBYlyXtOaAtu3ylBZSTkel
RwGTI0U9kQzIvU83m946eqgcZjmMnlRYwS9Gko6zQmmaTQFwuZZpShyD7TIqGKEGCF4hI3DFDKB2
+UPRYvnOFKrC9zVg/WRUlwoYU2o6GbfA0RK5aeaeAFN6JJYQ+ZPNndXnGKWwsNj3XZdhSnlSEvhE
PgHCBmc6RrqbJdfNVagWVwkUuUpJnLtckZkFygsoD81kPFemXmzeg+i9uy2M5vu2K1dz98zMN1iL
UTmdkL7kkUpEcqHeMSzV68+yktfFbhU77aZ5O8eu2uTLGq6HH6D1Ouob7dKPYEfRz78jkwqK3Sww
C6aqtF1gPyxDgPGV81IpSZYcghmehJ3J0Y5YSpQw5aGxd9Ubdl8xBA3kQhy/HdW9nPhIUC9DmdWj
wTic9zbqDaWAqlJMUsCjwYK5qQRafqkWlqTX8J0sizVMUWjBg4lgBZAxs7KneE6BmIBElFDQjdkU
odZjyqXy30mGNBCUJE3WpSbLVXUYhJitKBamwYOLR7ahCFegoaInFHVA6hFFVpAeyWTIMYlb3BNA
LyQSlWUjLT4uAU2qWceSXHhs0nJt34bKaZqtwi1CeaAo64Qq3CAxQGEQlaBgyt0SFMKwrtVrENcS
xmNjWmdVVqmcaxCJkCRJy55QVqMZaeXaqt4q4GNMiFjMurLg79dAHobSm3yCOyKMgE2R67IXCbDg
MJXGcA0zIRY0zzvDN/Xkd7kReab9qQfa/SgPCwGokewx3vYHHJWR79E2t3bHMPoa0JUg2pP/OHsw
R4jUHEWtRtnTEa5vgqa6n1B9uqzOTfvhNtQwm25EQLwxCsA23TLMnsBYQWEJZIPl1Q7WGYSjjeYs
UW6PdMnd0QCR0dJAjEf5GBlqjQIDzfQpJVBpIPY0g7Ow6zqIe0h9W2ZLQjvcjZlCvGCjShjxkDC8
uoAXlI6TQLIQdAiH9mdxD2fr9SVckG6xjFP/i7kinChINXgnroA=

--Boundary-00=_wXI8E8FVAQxxYzi--
Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
