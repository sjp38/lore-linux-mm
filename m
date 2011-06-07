Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 653746B0012
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 23:34:06 -0400 (EDT)
Message-ID: <4DED9C23.2030408@fnarfbargle.com>
Date: Tue, 07 Jun 2011 11:33:55 +0800
From: Brad Campbell <brad@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com> <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com> <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com> <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com> <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com> <isavsg$3or$1@dough.gmane.org> <4DE906C0.6060901@fnarfbargle.com> <4DED344D.7000005@pandora.be>
In-Reply-To: <4DED344D.7000005@pandora.be>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart De Schuymer <bdschuym@pandora.be>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On 07/06/11 04:10, Bart De Schuymer wrote:
> Hi Brad,
>
> This has probably nothing to do with ebtables, so please rmmod in case
> it's loaded.
> A few questions I didn't directly see an answer to in the threads I
> scanned...
> I'm assuming you actually use the bridging firewall functionality. So,
> what iptables modules do you use? Can you reduce your iptables rules to
> a core that triggers the bug?
> Or does it get triggered even with an empty set of firewall rules?
> Are you using a stock .35 kernel or is it patched?
> Is this something I can trigger on a poor guy's laptop or does it
> require specialized hardware (I'm catching up on qemu/kvm...)?

Not specialised hardware as such, I've just not been able to reproduce 
it outside of this specific operating scenario.

I can't trigger it with empty firewall rules as it relies on a DNAT to 
occur. If I try it directly to the internal IP address (as I have to 
without netfilter loaded) then of course nothing fails.

It's a pain in the bum as a fault, but it's one I can easily reproduce 
as long as I use the same set of circumstances.

I'll try using 3.0-rc2 (current git) tonight, and if I can reproduce it 
on that then I'll attempt to pare down the IPTABLES rules to a bare minimum.

It is nothing to do with ebtables as I don't compile it. I'm not really 
sure about "bridging firewall" functionality. I just use a couple of 
hand coded bash scripts to set the tables up.

brad@srv:~$ lsmod
Module                  Size  Used by
xt_iprange              1637  1
xt_DSCP                 2077  2
xt_length               1216  1
xt_CLASSIFY             1091  26
sch_sfq                 6681  4
xt_CHECKSUM             1229  2 brad@srv:~$ lsmod
Module                  Size  Used by
xt_iprange              1637  1
xt_DSCP                 2077  2
xt_length               1216  1
xt_CLASSIFY             1091  26
sch_sfq                 6681  4
xt_CHECKSUM             1229  2
ipt_REJECT              2277  1
ipt_MASQUERADE          1759  7
ipt_REDIRECT            1133  1
xt_recent               8223  2
xt_state                1226  5
iptable_nat             3993  1
nf_nat                 16773  3 ipt_MASQUERADE,ipt_REDIRECT,iptable_nat
nf_conntrack_ipv4      11868  8 iptable_nat,nf_nat
nf_conntrack           60962  5 
ipt_MASQUERADE,xt_state,iptable_nat,nf_nat,nf_conntrack_ipv4
nf_defrag_ipv4          1417  1 nf_conntrack_ipv4
xt_TCPMSS               2567  2
xt_tcpmss               1469  0
xt_tcpudp               2467  56
iptable_mangle          1487  1
pppoe                   9574  2
pppox                   2188  1 pppoe
iptable_filter          1442  1
ip_tables              16762  3 iptable_nat,iptable_mangle,iptable_filter
x_tables               20462  17 
xt_iprange,xt_DSCP,xt_length,xt_CLASSIFY,xt_CHECKSUM,ipt_REJECT,ipt_MASQUERADE,ipt_REDIRECT,xt_recent,xt_state,iptable_nat,xt_TCPMSS,xt_tcpmss,xt_tcpudp,iptable_mangle,iptable_filter,ip_tables
ppp_generic            24243  6 pppoe,pppox
slhc                    5293  1 ppp_generic
cls_u32                 6468  6
sch_htb                14432  2
deflate                 1937  0
zlib_deflate           21228  1 deflate
des_generic            16135  0
cbc                     2721  0
ecb                     1975  0
crypto_blkcipher       13645  2 cbc,ecb
sha1_generic            2095  0
md5                     4001  0
hmac                    2977  0
crypto_hash            14519  3 sha1_generic,md5,hmac
cryptomgr               2636  0
aead                    6137  1 cryptomgr
crypto_algapi          15289  9 
deflate,des_generic,cbc,ecb,crypto_blkcipher,hmac,crypto_hash,cryptomgr,aead
af_key                 27372  0
fuse                   66747  1
w83627ehf              32052  0
hwmon_vid               2867  1 w83627ehf
vhost_net              16802  6
powernow_k8            12932  0
mperf                   1263  1 powernow_k8
kvm_amd                53431  24
kvm                   235155  1 kvm_amd
pl2303                 12732  1
xhci_hcd               62865  0
i2c_piix4               8391  0
k10temp                 3183  0
usbserial              34452  3 pl2303
usb_storage            37887  1
usb_libusual           10999  1 usb_storage
ohci_hcd               18105  0
ehci_hcd               33641  0
ahci                   20748  4
usbcore               130936  7 
pl2303,xhci_hcd,usbserial,usb_storage,usb_libusual,ohci_hcd,ehci_hcd
libahci                21202  1 ahci
sata_mv                26939  0
megaraid_sas           71659  14

Nat Table (external ip substituted for xxx.xxx.xxx.xxx)

Chain PREROUTING (policy ACCEPT 1761K packets, 152M bytes)
  pkts bytes target     prot opt in     out     source 
destination
     5   210 DNAT       udp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           udp dpt:1195 to:192.168.253.199
     6   252 DNAT       udp  --  !ppp0  *       0.0.0.0/0 
xxx.xxx.xxx.xxx       udp dpt:1195 to:192.168.253.199
     0     0 DNAT       tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:25001 to:192.168.253.199:465
     0     0 DNAT       tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:25000 to:192.168.253.199:993
     0     0 DNAT       tcp  --  !ppp0  *       0.0.0.0/0 
xxx.xxx.xxx.xxx       tcp dpt:25001 to:192.168.253.199:465
     0     0 DNAT       tcp  --  !ppp0  *       0.0.0.0/0 
xxx.xxx.xxx.xxx       tcp dpt:25000 to:192.168.253.199:993
     2   142 DNAT       47   --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           to:192.168.253.199
    18   880 DNAT       tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:1723 to:192.168.253.199
     0     0 DNAT       47   --  !ppp0  *       0.0.0.0/0 
xxx.xxx.xxx.xxx       to:192.168.253.199
     0     0 DNAT       tcp  --  !ppp0  *       0.0.0.0/0 
xxx.xxx.xxx.xxx       tcp dpt:1723 to:192.168.253.199
  2969  149K DNAT       tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:443 to:192.168.253.198
    20  1280 DNAT       tcp  --  !ppp0  *       0.0.0.0/0 
xxx.xxx.xxx.xxx       tcp dpt:443 to:192.168.253.198
     0     0 DNAT       tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:3101 to:192.168.253.197
     0     0 DNAT       tcp  --  !ppp0  *       0.0.0.0/0 
xxx.xxx.xxx.xxx       tcp dpt:3101 to:192.168.253.197
     0     0 DNAT       tcp  --  !ppp0  *       0.0.0.0/0 
xxx.xxx.xxx.xxx       tcp dpt:4101 to:192.168.253.197
44528 2718K REDIRECT   tcp  --  !ppp0  *       0.0.0.0/0 
!192.168.0.0/16      tcp dpt:80 redir ports 8080
     0     0 DNAT       tcp  --  *      *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:3724 to:192.168.2.107
  596K   33M DNAT       tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpts:2001:2030 to:10.99.99.2
1420K  119M DNAT       udp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           udp dpts:2001:2030 to:10.99.99.2
  7483  449K DNAT       all  --  !ppp0  *       0.0.0.0/0 
xxx.xxx.xxx.xxx       to:192.168.2.1


Mangle Table

Chain INPUT (policy ACCEPT 270K packets, 17M bytes)
  pkts bytes target     prot opt in     out     source 
destination

Chain OUTPUT (policy ACCEPT 170K packets, 12M bytes)
  pkts bytes target     prot opt in     out     source 
destination

Chain POSTROUTING (policy ACCEPT 2205K packets, 166M bytes)
  pkts bytes target     prot opt in     out     source 
destination
     0     0 MASQUERADE  all  --  *      *       0.0.0.0/0 
192.168.254.3
     6   360 ACCEPT     all  --  *      *       0.0.0.0/0 
xxx.xxx.xxx.xxx
20424 2120K MASQUERADE  all  --  *      ppp0    192.168.0.0/16 
!192.168.0.0/16
     0     0 MASQUERADE  all  --  *      ppp0    10.0.0.0/24 
0.0.0.0/0
     3   204 MASQUERADE  all  --  *      *       192.168.2.0/24 
10.8.0.0/24
1418K  128M MASQUERADE  all  --  *      *       10.99.99.0/24 
0.0.0.0/0
68248 4095K MASQUERADE  all  --  *      *       192.168.253.0/24 
10.8.0.0/16
13305 2405K MASQUERADE  all  --  *      *       192.168.253.0/24 
!192.168.0.0/16

Chain PREROUTING (policy ACCEPT 278M packets, 293G bytes)
  pkts bytes target     prot opt in     out     source 
destination
   169 55528 CHECKSUM   udp  --  br1    *       0.0.0.0/0 
0.0.0.0/0           udp dpt:67 CHECKSUM fill

Chain INPUT (policy ACCEPT 180M packets, 250G bytes)
  pkts bytes target     prot opt in     out     source 
destination

Chain FORWARD (policy ACCEPT 98M packets, 44G bytes)
  pkts bytes target     prot opt in     out     source 
destination

Chain OUTPUT (policy ACCEPT 155M packets, 180G bytes)
  pkts bytes target     prot opt in     out     source 
destination

Chain POSTROUTING (policy ACCEPT 253M packets, 223G bytes)
  pkts bytes target     prot opt in     out     source 
destination
   165 54182 CHECKSUM   udp  --  *      br1     0.0.0.0/0 
0.0.0.0/0           udp spt:67 CHECKSUM fill
    51  3712 CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp dpt:53 CLASSIFY set 1:20
85274 6454K CLASSIFY   udp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           udp dpt:53 CLASSIFY set 1:20
   187  257K CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp spt:81 CLASSIFY set 1:20
   25M 1180M CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp flags:0x3F/0x10 state ESTABLISHED length 40:100 
CLASSIFY set 1:15
  728K   67M CLASSIFY   icmp --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           CLASSIFY set 1:15
   231 23484 CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp dpt:2401 CLASSIFY set 1:15
65636 5610K CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp dpt:22 CLASSIFY set 1:10
  2018  315K CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp spt:22 CLASSIFY set 1:10
    80 10092 CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp dpt:3389 CLASSIFY set 1:10
26063 8910K CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp dpt:8080 CLASSIFY set 1:15
  932K  131M CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp dpt:80 CLASSIFY set 1:15
  3511  267K CLASSIFY   udp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           udp dpt:123 CLASSIFY set 1:10
     0     0 CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp spt:20 CLASSIFY set 1:15
     3   180 CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp dpt:20 CLASSIFY set 1:15
94058   38M CLASSIFY   47   --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           CLASSIFY set 1:10
1086K  183M CLASSIFY   udp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           udp spt:1194 CLASSIFY set 1:10
1086K  183M TOS        udp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           udp spt:1194 TOS set 0x10/0x3f
48817   10M CLASSIFY   udp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           udp spt:1195 CLASSIFY set 1:10
48817   10M TOS        udp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           udp spt:1195 TOS set 0x10/0x3f
94058   38M CLASSIFY   47   --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           CLASSIFY set 1:15
   106  7207 CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp dpt:1863 CLASSIFY set 1:15
  188K   34M CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp dpt:443 CLASSIFY set 1:15
51541 3327K CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp dpts:6660:6669 CLASSIFY set 1:15
     0     0 CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp spts:2021:2030 CLASSIFY set 1:15
    85  4944 CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp dpt:19999 CLASSIFY set 1:15
  208K   86M CLASSIFY   udp  --  *      *       0.0.0.0/0 
0.0.0.0/0           source IP range 192.168.2.80-192.168.2.120 CLASSIFY 
set 1:10
     0     0 CLASSIFY   tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp spt:12345 CLASSIFY set 1:15
     1    80 CLASSIFY   udp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           udp spt:12345 CLASSIFY set 1:15


Default table

Chain INPUT (policy ACCEPT 176M packets, 247G bytes)
  pkts bytes target     prot opt in     out     source 
destination
     0     0 ACCEPT     udp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           udp dpt:4569
1187K  582M ACCEPT     udp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           udp dpt:1194
     2   577 ACCEPT     udp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           udp dpt:1195
    28  1224 ACCEPT     tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:3389
   230 12372            tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:22 state NEW recent: SET name: DEFAULT side: 
source
     3   180 DROP       tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:22 state NEW recent: UPDATE seconds: 300 
hit_count: 4 name: DEFAULT side: source
  1750  143K ACCEPT     tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:22
     3   144 ACCEPT     tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:113
   120  6090 ACCEPT     tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:81
36094   29M ACCEPT     tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp dpt:25
1456K 1706M ACCEPT     all  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           state RELATED,ESTABLISHED
31047 2334K REJECT     tcp  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0           tcp option=!2 reject-with tcp-reset
  552K   60M ACCEPT     all  --  !ppp0  *       0.0.0.0/0 
0.0.0.0/0           state NEW
13552 1207K ACCEPT     icmp --  ppp0   *       0.0.0.0/0 
0.0.0.0/0
  5712  392K DROP       all  --  ppp0   *       0.0.0.0/0 
0.0.0.0/0

Chain FORWARD (policy ACCEPT 98M packets, 44G bytes)
  pkts bytes target     prot opt in     out     source 
destination
1207K   68M TCPMSS     tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp flags:0x06/0x02 TCPMSS clamp to PMTU

Chain OUTPUT (policy ACCEPT 155M packets, 180G bytes)
  pkts bytes target     prot opt in     out     source 
destination
31675 1895K TCPMSS     tcp  --  *      ppp0    0.0.0.0/0 
0.0.0.0/0           tcp flags:0x06/0x02 TCPMSS clamp to PMTU

lsmod

ipt_REJECT              2277  1
ipt_MASQUERADE          1759  7
ipt_REDIRECT            1133  1
xt_recent               8223  2
xt_state                1226  5
iptable_nat             3993  1
nf_nat                 16773  3 ipt_MASQUERADE,ipt_REDIRECT,iptable_nat
nf_conntrack_ipv4      11868  8 iptable_nat,nf_nat
nf_conntrack           60962  5 
ipt_MASQUERADE,xt_state,iptable_nat,nf_nat,nf_conntrack_ipv4
nf_defrag_ipv4          1417  1 nf_conntrack_ipv4
xt_TCPMSS               2567  2
xt_tcpmss               1469  0
xt_tcpudp               2467  56
iptable_mangle          1487  1
pppoe                   9574  2
pppox                   2188  1 pppoe
iptable_filter          1442  1
ip_tables              16762  3 iptable_nat,iptable_mangle,iptable_filter
x_tables               20462  17 
xt_iprange,xt_DSCP,xt_length,xt_CLASSIFY,xt_CHECKSUM,ipt_REJECT,ipt_MASQUERADE,ipt_REDIRECT,xt_recent,xt_state,iptable_nat,xt_TCPMSS,xt_tcpmss,xt_tcpudp,iptable_mangle,iptable_filter,ip_tables
ppp_generic            24243  6 pppoe,pppox
slhc                    5293  1 ppp_generic
cls_u32                 6468  6
sch_htb                14432  2
deflate                 1937  0
zlib_deflate           21228  1 deflate
des_generic            16135  0
cbc                     2721  0
ecb                     1975  0
crypto_blkcipher       13645  2 cbc,ecb
sha1_generic            2095  0
md5                     4001  0
hmac                    2977  0
crypto_hash            14519  3 sha1_generic,md5,hmac
cryptomgr               2636  0
aead                    6137  1 cryptomgr
crypto_algapi          15289  9 
deflate,des_generic,cbc,ecb,crypto_blkcipher,hmac,crypto_hash,cryptomgr,aead
af_key                 27372  0
fuse                   66747  1
w83627ehf              32052  0
hwmon_vid               2867  1 w83627ehf
vhost_net              16802  6
powernow_k8            12932  0
mperf                   1263  1 powernow_k8
kvm_amd                53431  24
kvm                   235155  1 kvm_amd
pl2303                 12732  1
xhci_hcd               62865  0
i2c_piix4               8391  0
k10temp                 3183  0
usbserial              34452  3 pl2303
usb_storage            37887  1
usb_libusual           10999  1 usb_storage
ohci_hcd               18105  0
ehci_hcd               33641  0
ahci                   20748  4
usbcore               130936  7 
pl2303,xhci_hcd,usbserial,usb_storage,usb_libusual,ohci_hcd,ehci_hcd
libahci                21202  1 ahci
sata_mv                26939  0
megaraid_sas           71659  14

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
