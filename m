Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA8EC6B000C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 10:31:04 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g11-v6so1938184edi.8
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 07:31:04 -0700 (PDT)
Received: from mx1.molgen.mpg.de (mx3.molgen.mpg.de. [141.14.17.11])
        by mx.google.com with ESMTPS id y19-v6si305334edm.267.2018.07.18.07.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 07:31:02 -0700 (PDT)
From: Paul Menzel <pmenzel+linux-mm@molgen.mpg.de>
Subject: general protection fault with prefetch_freepointer
Message-ID: <333cfb75-1769-c67f-c56f-c9458368751a@molgen.mpg.de>
Date: Wed, 18 Jul 2018 16:31:00 +0200
MIME-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; boundary="------------ms040508060408000908050606"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is a cryptographically signed message in MIME format.

--------------ms040508060408000908050606
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

Dear Linux,


Loading the amdgpu module on Ryzen 3 2{2,4}00G (Raven) systems sometimes
causes a general protection fault [1]. At least on my system I am unable
to reliably reproduce the issue.

```
[   35.265941] kfd kfd: kgd2kfd_probe failed
[   35.537445] general protection fault: 0000 [#1] SMP NOPTI
[   35.543209] CPU: 0 PID: 367 Comm: systemd-udevd Not tainted 4.18.0-rc5=
+ #1
[   35.550371] Hardware name: MSI MS-7A37/B350M MORTAR (MS-7A37), BIOS 1.=
G1 05/17/2018
[   35.558562] RIP: 0010:prefetch_freepointer+0x10/0x20
[   35.563881] Code: 89 d3 e8 c3 fe 4a 00 85 c0 0f 85 31 75 00 00 48 83 c=
4 08 5b 5d 41 5c 41 5d c3 0f 1f 44 00 00 48 85 f6 74 13 8b 47 20 48 01 c6=
 <48> 33 36 48 33 b7 38 01 00 00 0f 18 0e c3 66 90 0f 1f 44 00 00 48=20
[   35.584215] RSP: 0018:ffff9c3181f77560 EFLAGS: 00010202
[   35.589849] RAX: 0000000000000000 RBX: 4b2c8be0a60f6ab9 RCX: 000000000=
0000ccc
[   35.597492] RDX: 0000000000000ccb RSI: 4b2c8be0a60f6ab9 RDI: ffff8d5b1=
e406e80
[   35.605166] RBP: ffff8d5b1e406e80 R08: ffff8d5b1e824f00 R09: ffffffffc=
0a45423
[   35.612808] R10: fffff1b60fff64c0 R11: ffff9c3181f77520 R12: 000000000=
06080c0
[   35.620451] R13: 0000000000000230 R14: ffff8d5b1e406e80 R15: ffff8d5b0=
c304400
[   35.628116] FS:  00007fb194e4b8c0(0000) GS:ffff8d5b1e800000(0000) knlG=
S:0000000000000000
[   35.636771] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   35.642931] CR2: 000055c0661d60d0 CR3: 000000040b9ee000 CR4: 000000000=
03406f0
[   35.650566] Call Trace:
[   35.653198]  kmem_cache_alloc_trace+0xb5/0x1c0
[   35.658077]  ? dal_ddc_service_create+0x38/0x110 [amdgpu]
[   35.663962]  dal_ddc_service_create+0x38/0x110 [amdgpu]
```

Do you have more ideas, how to debug that? The progress in bug report
kind of stalled as people have run out of ideas.

I thought about a hardware/firmware problem, but then searching for the
error, I found the stack trace with Linux 4.17.2 from Fedora [2][3].
This looks a little similar, but can of course be something totally
different.

```
general protection fault: 0000 [#1] SMP PTI
Modules linked in: sctp netlink_diag nfsv3 nfnetlink_queue nfnetlink_log =
nfnetlink cfg80211 rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache rfcomm =
fuse hidp xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv=
4 xt_conntrack tun devlink ebtable_filter ebtables ip6table_filter ip6_ta=
bles iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_c=
onntrack bridge stp llc bnep it87 hwmon_vid btrfs xor zstd_compress raid6=
_pq libcrc32c zstd_decompress xxhash intel_rapl x86_pkg_temp_thermal inte=
l_powerclamp coretemp kvm_intel kvm gpio_ich iTCO_wdt iTCO_vendor_support=
 ppdev irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel intel_=
cstate intel_uncore intel_rapl_perf btusb btrtl btbcm btintel bluetooth s=
nd_hda_codec_realtek snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_int=
el
 snd_hda_codec ecdh_generic rfkill snd_hda_core snd_hwdep snd_seq snd_seq=
_device snd_pcm snd_timer i2c_i801 lpc_ich mei_me mei shpchp snd soundcor=
e parport_pc parport nfsd binfmt_misc nfs_acl lockd auth_rpcgss grace sun=
rpc i915 crc32c_intel i2c_algo_bit drm_kms_helper serio_raw drm r8169 sat=
a_via mii video
CPU: 0 PID: 2690 Comm: nfsd Not tainted 4.17.2-200.fc28.x86_64 #1
Hardware name: Gigabyte Technology Co., Ltd. H81M-S2PV/H81M-S2PV, BIOS F8=
 06/19/2014
RIP: 0010:prefetch_freepointer+0x10/0x20
RSP: 0018:ffffa33fca4ebc58 EFLAGS: 00010202
RAX: 0000000000000000 RBX: 49f929d076783c7f RCX: 0000000000000f2a
RDX: 0000000000000f29 RSI: 49f929d076783c7f RDI: ffff8da88c9ffe00
RBP: ffff8da88c9ffe00 R08: ffff8da89ee2b100 R09: 0000000000000004
R10: 0000000000000000 R11: 000000000000002c R12: 00000000014080c0
R13: ffffffffc07e0ac1 R14: ffff8da4bc958ae1 R15: ffff8da88c9ffe00
FS:  0000000000000000(0000) GS:ffff8da89ee00000(0000) knlGS:0000000000000=
000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00002001a1783000 CR3: 000000012920a001 CR4: 00000000000606f0
Call Trace:
 kmem_cache_alloc+0xb4/0x1d0
 ? nfsd4_free_file_rcu+0x20/0x20 [nfsd]
```

Help on how to debug this is appreciated.


Kind regards,

Paul


[1]: https://bugs.freedesktop.org/show_bug.cgi?id=3D105684
[2]: https://bugzilla.redhat.com/show_bug.cgi?id=3D1600482
[3]: https://retrace.fedoraproject.org/faf/reports/2243945/


--------------ms040508060408000908050606
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCC
EFowggUSMIID+qADAgECAgkA4wvV+K8l2YEwDQYJKoZIhvcNAQELBQAwgYIxCzAJBgNVBAYT
AkRFMSswKQYDVQQKDCJULVN5c3RlbXMgRW50ZXJwcmlzZSBTZXJ2aWNlcyBHbWJIMR8wHQYD
VQQLDBZULVN5c3RlbXMgVHJ1c3QgQ2VudGVyMSUwIwYDVQQDDBxULVRlbGVTZWMgR2xvYmFs
Um9vdCBDbGFzcyAyMB4XDTE2MDIyMjEzMzgyMloXDTMxMDIyMjIzNTk1OVowgZUxCzAJBgNV
BAYTAkRFMUUwQwYDVQQKEzxWZXJlaW4genVyIEZvZXJkZXJ1bmcgZWluZXMgRGV1dHNjaGVu
IEZvcnNjaHVuZ3NuZXR6ZXMgZS4gVi4xEDAOBgNVBAsTB0RGTi1QS0kxLTArBgNVBAMTJERG
Ti1WZXJlaW4gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgMjCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBAMtg1/9moUHN0vqHl4pzq5lN6mc5WqFggEcVToyVsuXPztNXS43O+FZs
FVV2B+pG/cgDRWM+cNSrVICxI5y+NyipCf8FXRgPxJiZN7Mg9mZ4F4fCnQ7MSjLnFp2uDo0p
eQcAIFTcFV9Kltd4tjTTwXS1nem/wHdN6r1ZB+BaL2w8pQDcNb1lDY9/Mm3yWmpLYgHurDg0
WUU2SQXaeMpqbVvAgWsRzNI8qIv4cRrKO+KA3Ra0Z3qLNupOkSk9s1FcragMvp0049ENF4N1
xDkesJQLEvHVaY4l9Lg9K7/AjsMeO6W/VRCrKq4Xl14zzsjz9AkH4wKGMUZrAcUQDBHHWekC
AwEAAaOCAXQwggFwMA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUk+PYMiba1fFKpZFK4OpL
4qIMz+EwHwYDVR0jBBgwFoAUv1kgNgB5oKAia4zV8mHSuCzLgkowEgYDVR0TAQH/BAgwBgEB
/wIBAjAzBgNVHSAELDAqMA8GDSsGAQQBga0hgiwBAQQwDQYLKwYBBAGBrSGCLB4wCAYGZ4EM
AQICMEwGA1UdHwRFMEMwQaA/oD2GO2h0dHA6Ly9wa2kwMzM2LnRlbGVzZWMuZGUvcmwvVGVs
ZVNlY19HbG9iYWxSb290X0NsYXNzXzIuY3JsMIGGBggrBgEFBQcBAQR6MHgwLAYIKwYBBQUH
MAGGIGh0dHA6Ly9vY3NwMDMzNi50ZWxlc2VjLmRlL29jc3ByMEgGCCsGAQUFBzAChjxodHRw
Oi8vcGtpMDMzNi50ZWxlc2VjLmRlL2NydC9UZWxlU2VjX0dsb2JhbFJvb3RfQ2xhc3NfMi5j
ZXIwDQYJKoZIhvcNAQELBQADggEBAIcL/z4Cm2XIVi3WO5qYi3FP2ropqiH5Ri71sqQPrhE4
eTizDnS6dl2e6BiClmLbTDPo3flq3zK9LExHYFV/53RrtCyD2HlrtrdNUAtmB7Xts5et6u5/
MOaZ/SLick0+hFvu+c+Z6n/XUjkurJgARH5pO7917tALOxrN5fcPImxHhPalR6D90Bo0fa3S
PXez7vTXTf/D6OWST1k+kEcQSrCFWMBvf/iu7QhCnh7U3xQuTY+8npTD5+32GPg8SecmqKc2
2CzeIs2LgtjZeOJVEqM7h0S2EQvVDFKvaYwPBt/QolOLV5h7z/0HJPT8vcP9SpIClxvyt7bP
ZYoaorVyGTkwggWNMIIEdaADAgECAgwcOtRQhH7u81j4jncwDQYJKoZIhvcNAQELBQAwgZUx
CzAJBgNVBAYTAkRFMUUwQwYDVQQKEzxWZXJlaW4genVyIEZvZXJkZXJ1bmcgZWluZXMgRGV1
dHNjaGVuIEZvcnNjaHVuZ3NuZXR6ZXMgZS4gVi4xEDAOBgNVBAsTB0RGTi1QS0kxLTArBgNV
BAMTJERGTi1WZXJlaW4gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgMjAeFw0xNjExMDMxNTI0
NDhaFw0zMTAyMjIyMzU5NTlaMGoxCzAJBgNVBAYTAkRFMQ8wDQYDVQQIDAZCYXllcm4xETAP
BgNVBAcMCE11ZW5jaGVuMSAwHgYDVQQKDBdNYXgtUGxhbmNrLUdlc2VsbHNjaGFmdDEVMBMG
A1UEAwwMTVBHIENBIC0gRzAyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnhx4
59Lh4WqgOs/Md04XxU2yFtfM15ZuJV0PZP7BmqSJKLLPyqmOrADfNdJ5PIGBto2JBhtRRBHd
G0GROOvTRHjzOga95WOTeura79T21FWwwAwa29OFnD3ZplQs6HgdwQrZWNi1WHNJxn/4mA19
rNEBUc5urSIpZPvZi5XmlF3v3JHOlx3KWV7mUteB4pwEEfGTg4npPAJbp2o7arxQdoIq+Pu2
OsvqhD7Rk4QeaX+EM1QS4lqd1otW4hE70h/ODPy1xffgbZiuotWQLC6nIwa65Qv6byqlIX0q
Zuu99Vsu+r3sWYsL5SBkgecNI7fMJ5tfHrjoxfrKl/ErTAt8GQIDAQABo4ICBTCCAgEwEgYD
VR0TAQH/BAgwBgEB/wIBATAOBgNVHQ8BAf8EBAMCAQYwKQYDVR0gBCIwIDANBgsrBgEEAYGt
IYIsHjAPBg0rBgEEAYGtIYIsAQEEMB0GA1UdDgQWBBTEiKUH7rh7qgwTv9opdGNSG0lwFjAf
BgNVHSMEGDAWgBST49gyJtrV8UqlkUrg6kviogzP4TCBjwYDVR0fBIGHMIGEMECgPqA8hjpo
dHRwOi8vY2RwMS5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWcyLWNhL3B1Yi9jcmwvY2Fjcmwu
Y3JsMECgPqA8hjpodHRwOi8vY2RwMi5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWcyLWNhL3B1
Yi9jcmwvY2FjcmwuY3JsMIHdBggrBgEFBQcBAQSB0DCBzTAzBggrBgEFBQcwAYYnaHR0cDov
L29jc3AucGNhLmRmbi5kZS9PQ1NQLVNlcnZlci9PQ1NQMEoGCCsGAQUFBzAChj5odHRwOi8v
Y2RwMS5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWcyLWNhL3B1Yi9jYWNlcnQvY2FjZXJ0LmNy
dDBKBggrBgEFBQcwAoY+aHR0cDovL2NkcDIucGNhLmRmbi5kZS9nbG9iYWwtcm9vdC1nMi1j
YS9wdWIvY2FjZXJ0L2NhY2VydC5jcnQwDQYJKoZIhvcNAQELBQADggEBABLpeD5FygzqOjj+
/lAOy20UQOGWlx0RMuPcI4nuyFT8SGmK9lD7QCg/HoaJlfU/r78ex+SEide326evlFAoJXIF
jVyzNltDhpMKrPIDuh2N12zyn1EtagqPL6hu4pVRzcBpl/F2HCvtmMx5K4WN1L1fmHWLcSap
dhXLvAZ9RG/B3rqyULLSNN8xHXYXpmtvG0VGJAndZ+lj+BH7uvd3nHWnXEHC2q7iQlDUqg0a
wIqWJgdLlx1Q8Dg/sodv0m+LN0kOzGvVDRCmowBdWGhhusD+duKV66pBl+qhC+4LipariWaM
qK5ppMQROATjYeNRvwI+nDcEXr2vDaKmdbxgDVwwggWvMIIEl6ADAgECAgweKlJIhfynPMVG
/KIwDQYJKoZIhvcNAQELBQAwajELMAkGA1UEBhMCREUxDzANBgNVBAgMBkJheWVybjERMA8G
A1UEBwwITXVlbmNoZW4xIDAeBgNVBAoMF01heC1QbGFuY2stR2VzZWxsc2NoYWZ0MRUwEwYD
VQQDDAxNUEcgQ0EgLSBHMDIwHhcNMTcxMTE0MTEzNDE2WhcNMjAxMTEzMTEzNDE2WjCBizEL
MAkGA1UEBhMCREUxIDAeBgNVBAoMF01heC1QbGFuY2stR2VzZWxsc2NoYWZ0MTQwMgYDVQQL
DCtNYXgtUGxhbmNrLUluc3RpdHV0IGZ1ZXIgbW9sZWt1bGFyZSBHZW5ldGlrMQ4wDAYDVQQL
DAVNUElNRzEUMBIGA1UEAwwLUGF1bCBNZW56ZWwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
ggEKAoIBAQDIh/UR/AX/YQ48VWWDMLTYtXjYJyhRHMc81ZHMMoaoG66lWB9MtKRTnB5lovLZ
enTIUyPsCrMhTqV9CWzDf6v9gOTWVxHEYqrUwK5H1gx4XoK81nfV8oGV4EKuVmmikTXiztGz
peyDmOY8o/EFNWP7YuRkY/lPQJQBeBHYq9AYIgX4StuXu83nusq4MDydygVOeZC15ts0tv3/
6WmibmZd1OZRqxDOkoBbY3Djx6lERohs3IKS6RKiI7e90rCSy9rtidJBOvaQS9wvtOSKPx0a
+2pAgJEVzZFjOAfBcXydXtqXhcpOi2VCyl+7+LnnTz016JJLsCBuWEcB3kP9nJYNAgMBAAGj
ggIxMIICLTAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIF4DAdBgNVHSUEFjAUBggrBgEFBQcD
AgYIKwYBBQUHAwQwHQYDVR0OBBYEFHM0Mc3XjMLlhWpp4JufRELL4A/qMB8GA1UdIwQYMBaA
FMSIpQfuuHuqDBO/2il0Y1IbSXAWMCAGA1UdEQQZMBeBFXBtZW56ZWxAbW9sZ2VuLm1wZy5k
ZTB9BgNVHR8EdjB0MDigNqA0hjJodHRwOi8vY2RwMS5wY2EuZGZuLmRlL21wZy1nMi1jYS9w
dWIvY3JsL2NhY3JsLmNybDA4oDagNIYyaHR0cDovL2NkcDIucGNhLmRmbi5kZS9tcGctZzIt
Y2EvcHViL2NybC9jYWNybC5jcmwwgc0GCCsGAQUFBwEBBIHAMIG9MDMGCCsGAQUFBzABhido
dHRwOi8vb2NzcC5wY2EuZGZuLmRlL09DU1AtU2VydmVyL09DU1AwQgYIKwYBBQUHMAKGNmh0
dHA6Ly9jZHAxLnBjYS5kZm4uZGUvbXBnLWcyLWNhL3B1Yi9jYWNlcnQvY2FjZXJ0LmNydDBC
BggrBgEFBQcwAoY2aHR0cDovL2NkcDIucGNhLmRmbi5kZS9tcGctZzItY2EvcHViL2NhY2Vy
dC9jYWNlcnQuY3J0MEAGA1UdIAQ5MDcwDwYNKwYBBAGBrSGCLAEBBDARBg8rBgEEAYGtIYIs
AQEEAwYwEQYPKwYBBAGBrSGCLAIBBAMGMA0GCSqGSIb3DQEBCwUAA4IBAQCQs6bUDROpFO2F
Qz2FMgrdb39VEo8P3DhmpqkaIMC5ZurGbbAL/tAR6lpe4af682nEOJ7VW86ilsIJgm1j0ueY
aOuL8jrN4X7IF/8KdZnnNnImW3QVni6TCcc+7+ggci9JHtt0IDCj5vPJBpP/dKXLCN4M+exl
GXYpfHgxh8gclJPY1rquhQrihCzHfKB01w9h9tWZDVMtSoy9EUJFhCXw7mYUsvBeJwZesN2B
fndPkrXx6XWDdU3S1LyKgHlLIFtarLFm2Hb5zAUR33h+26cN6ohcGqGEEzgIG8tXS8gztEaj
1s2RyzmKd4SXTkKR3GhkZNVWy+gM68J7jP6zzN+cMYIDmjCCA5YCAQEwejBqMQswCQYDVQQG
EwJERTEPMA0GA1UECAwGQmF5ZXJuMREwDwYDVQQHDAhNdWVuY2hlbjEgMB4GA1UECgwXTWF4
LVBsYW5jay1HZXNlbGxzY2hhZnQxFTATBgNVBAMMDE1QRyBDQSAtIEcwMgIMHipSSIX8pzzF
RvyiMA0GCWCGSAFlAwQCAQUAoIIB8TAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqG
SIb3DQEJBTEPFw0xODA3MTgxNDMxMDBaMC8GCSqGSIb3DQEJBDEiBCDZMqEFv7UUMqSoHO2O
EkCVqh3dvt681jYaxgHYYM83xDBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjALBglg
hkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcG
BSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGJBgkrBgEEAYI3EAQxfDB6MGoxCzAJBgNVBAYTAkRF
MQ8wDQYDVQQIDAZCYXllcm4xETAPBgNVBAcMCE11ZW5jaGVuMSAwHgYDVQQKDBdNYXgtUGxh
bmNrLUdlc2VsbHNjaGFmdDEVMBMGA1UEAwwMTVBHIENBIC0gRzAyAgweKlJIhfynPMVG/KIw
gYsGCyqGSIb3DQEJEAILMXygejBqMQswCQYDVQQGEwJERTEPMA0GA1UECAwGQmF5ZXJuMREw
DwYDVQQHDAhNdWVuY2hlbjEgMB4GA1UECgwXTWF4LVBsYW5jay1HZXNlbGxzY2hhZnQxFTAT
BgNVBAMMDE1QRyBDQSAtIEcwMgIMHipSSIX8pzzFRvyiMA0GCSqGSIb3DQEBAQUABIIBAHrd
RriGLUdG2vsrk0onBm1/7bPON5yjo7ODn+xdKZStGNCy2cgakREmLLUZsfLRQql8tRBNkWNc
MGQAG5qPPQwqBFJIXc6zMjjBZppQU+7GDmbP6oI9YtTiQsrOI5W6JWnz8VqxQAowvQjmpxC3
01rwr+zwOTL8/P+gAhgXX+vcBb0kAhZmZ2cRH23zUM0efDeMqHHCUdPgzG4BIxP/NbkXNr9c
KswUlBIE1WD5PGwtFbI17VpPAptPs8xQKWRMGsgTXrF+wxHzeiAfQR3MG4nYVAPJnzAe0dwH
254WpmC8Nqspd7X/DHfy4/0ekNF7t1laNFWVHcQNDxw1ZmN6yXEAAAAAAAA=
--------------ms040508060408000908050606--
